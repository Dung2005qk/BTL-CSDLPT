// ==================================================================
// HỆ THỐNG BÁN HÀNG TRỰC TUYẾN ĐA KHO — NODE.JS SERVER
// Kết nối 3 laptop SQL Server qua Radmin VPN
// ==================================================================
const express = require('express');
const sql = require('mssql');
const path = require('path');

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, 'demo')));

// ==================================================================
// CẤU HÌNH KẾT NỐI 3 MÁY (dùng Hostname, không dùng IP)
// ==================================================================
const configs = {
    S1: {
        server: 'LAPTOP-M3FKU757',
        database: 'CSDLPT',
        user: 'sa',
        password: 'Dung2005@',
        options: { encrypt: false, trustServerCertificate: true },
        pool: { max: 5, min: 1, idleTimeoutMillis: 30000 },
        requestTimeout: 60000
    },
    S2: {
        server: 'DESKTOP-Q5G45CD',
        database: 'CSDLPT',
        user: 'sa',
        password: '123456789',
        options: { encrypt: false, trustServerCertificate: true },
        pool: { max: 5, min: 1, idleTimeoutMillis: 30000 },
        requestTimeout: 60000
    },
    S3: {
        server: 'LAPTOP-UD52TRL3',
        database: 'CSDLPT',
        user: 'sa',
        password: '1234',
        options: { encrypt: false, trustServerCertificate: true },
        pool: { max: 5, min: 1, idleTimeoutMillis: 30000 },
        requestTimeout: 60000
    }
};

// Connection pools
let pools = {};

async function initPools() {
    for (const [name, config] of Object.entries(configs)) {
        try {
            const pool = new sql.ConnectionPool(config);
            pools[name] = await pool.connect();
            console.log(`✅ ${name} (${config.server}) — kết nối thành công`);
        } catch (err) {
            console.error(`❌ ${name} (${config.server}) — lỗi: ${err.message}`);
            pools[name] = null;
        }
    }
}

// Helper: query a specific pool
async function queryPool(poolName, sqlQuery, params) {
    const pool = pools[poolName];
    if (!pool) throw new Error(`${poolName} không khả dụng`);
    const request = pool.request();
    if (params) {
        for (const [key, val] of Object.entries(params)) {
            request.input(key, val);
        }
    }
    return request.query(sqlQuery);
}

// ==================================================================
// 5 TRUY VẤN PHÂN TÁN (chạy tại S1 — dùng Linked Server)
// ==================================================================
const QUERIES = {
    1: {
        name: 'Tồn kho điện tử tại kho K001 (Cục bộ S1)',
        sql: `SELECT P.TenSP, P.GiaBan, T.SoLuongTon
              FROM SP_PUBLIC P
              INNER JOIN TONKHO T ON P.MaSP = T.MaSP
              INNER JOIN KHO K ON T.MaKho = K.MaKho
              WHERE K.MaKho = 'K001' AND P.MaDM = 'DM01'`,
        technique: 'Cục bộ hóa hoàn toàn tại S1, chi phí truyền thông = 0'
    },
    2: {
        name: 'Tổng tồn kho SP001 toàn hệ thống',
        sql: `SELECT MaSP, SUM(SoLuongTon) AS TongTonKho
              FROM V_TONKHO WHERE MaSP = 'SP001'
              GROUP BY MaSP`,
        technique: 'Tổng hợp cục bộ qua View toàn cục — mỗi trạm gửi 1 giá trị'
    },
    3: {
        name: 'Đơn hàng miền Nam xuất từ kho miền Bắc',
        sql: `SELECT D.MaDH, D.MaKH COLLATE DATABASE_DEFAULT AS MaKH,
                     CT.MaSP COLLATE DATABASE_DEFAULT AS MaSP,
                     CT.MaKhoXuat COLLATE DATABASE_DEFAULT AS MaKhoXuat,
                     CT.SoLuong
              FROM [S3_MN].[CSDLPT].[dbo].[DONHANG] D
              INNER JOIN [S3_MN].[CSDLPT].[dbo].[CHITIETDONHANG] CT
                  ON D.MaDH COLLATE DATABASE_DEFAULT = CT.MaDH COLLATE DATABASE_DEFAULT
              WHERE CT.MaKhoXuat COLLATE DATABASE_DEFAULT IN (SELECT MaKho FROM KHO)`,
        technique: 'Phép nối nửa — gửi tập khóa MaKho từ S1 sang S3'
    },
    4: {
        name: 'Doanh thu theo khu vực',
        sql: `SELECT KhuVuc, SUM(DoanhThu) AS TongDoanhThu FROM (
                SELECT 'MB' AS KhuVuc, SUM(CT.SoLuong * CT.DonGia) AS DoanhThu
                FROM CHITIETDONHANG CT
                UNION ALL
                SELECT 'MT', SUM(CT.SoLuong * CT.DonGia)
                FROM [S2_MT].[CSDLPT].[dbo].[CHITIETDONHANG] CT
                UNION ALL
                SELECT 'MN', SUM(CT.SoLuong * CT.DonGia)
                FROM [S3_MN].[CSDLPT].[dbo].[CHITIETDONHANG] CT
              ) AS T GROUP BY KhuVuc ORDER BY TongDoanhThu DESC`,
        technique: 'Tổng hợp cục bộ 2 giai đoạn — GROUP BY tại mỗi trạm'
    },
    5: {
        name: 'Top 10 sản phẩm bán chạy',
        sql: `SELECT TOP 10 P.MaSP, P.TenSP, SUM(TongBan) AS TongSoLuongBan
              FROM SP_PUBLIC P
              INNER JOIN (
                SELECT MaSP COLLATE DATABASE_DEFAULT AS MaSP, SUM(SoLuong) AS TongBan
                FROM CHITIETDONHANG GROUP BY MaSP
                UNION ALL
                SELECT MaSP COLLATE DATABASE_DEFAULT, SUM(SoLuong)
                FROM [S2_MT].[CSDLPT].[dbo].[CHITIETDONHANG] GROUP BY MaSP
                UNION ALL
                SELECT MaSP COLLATE DATABASE_DEFAULT, SUM(SoLuong)
                FROM [S3_MN].[CSDLPT].[dbo].[CHITIETDONHANG] GROUP BY MaSP
              ) AS T ON P.MaSP = T.MaSP
              GROUP BY P.MaSP, P.TenSP
              ORDER BY TongSoLuongBan DESC`,
        technique: 'Nhân bản SP_PUBLIC + tổng hợp cục bộ'
    }
};

// ==================================================================
// API ENDPOINTS
// ==================================================================

// API: Trạng thái kết nối 3 máy
app.get('/api/status', async (req, res) => {
    const status = {};
    for (const [name, config] of Object.entries(configs)) {
        try {
            if (pools[name] && pools[name].connected) {
                await queryPool(name, 'SELECT 1 AS ping');
                status[name] = { online: true, host: config.server };
                // Try reconnect
                const pool = new sql.ConnectionPool(config);
                pools[name] = await pool.connect();
                status[name] = { online: true, host: config.server };
            }
        } catch {
            status[name] = { online: false, host: config.server };
        }
    }
    res.json(status);
});

// API: Thực thi truy vấn phân tán (chạy tại S1)
app.get('/api/query/:id', async (req, res) => {
    const id = parseInt(req.params.id);
    const q = QUERIES[id];
    if (!q) return res.status(404).json({ error: 'Truy vấn không tồn tại' });

    try {
        const t0 = Date.now();
        const result = await queryPool('S1', q.sql);
        const time = Date.now() - t0;
        res.json({ name: q.name, technique: q.technique, rows: result.recordset, time });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// API: Tồn kho sản phẩm (query song song 3 máy)
app.get('/api/inventory/:sp', async (req, res) => {
    const sp = req.params.sp;
    try {
        const results = await Promise.allSettled([
            queryPool('S1', `SELECT ISNULL(SUM(SoLuongTon),0) AS ton FROM TONKHO WHERE MaSP=@sp`, { sp }),
            queryPool('S2', `SELECT ISNULL(SUM(SoLuongTon),0) AS ton FROM TONKHO WHERE MaSP=@sp`, { sp }),
            queryPool('S3', `SELECT ISNULL(SUM(SoLuongTon),0) AS ton FROM TONKHO WHERE MaSP=@sp`, { sp })
        ]);

        const v1 = results[0].status === 'fulfilled' ? results[0].value.recordset[0].ton : 0;
        const v2 = results[1].status === 'fulfilled' ? results[1].value.recordset[0].ton : 0;
        const v3 = results[2].status === 'fulfilled' ? results[2].value.recordset[0].ton : 0;

        res.json({
            s1: { ton: v1, online: results[0].status === 'fulfilled' },
            s2: { ton: v2, online: results[1].status === 'fulfilled' },
            s3: { ton: v3, online: results[2].status === 'fulfilled' },
            total: v1 + v2 + v3
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// API: Thống kê tổng quan
app.get('/api/overview', async (req, res) => {
    try {
        const result = await queryPool('S1', `
            SELECT 'V_KHO' AS [View], COUNT(*) AS Cnt FROM V_KHO
            UNION ALL SELECT 'V_KHACHHANG', COUNT(*) FROM V_KHACHHANG
            UNION ALL SELECT 'V_TONKHO', COUNT(*) FROM V_TONKHO
            UNION ALL SELECT 'V_DONHANG', COUNT(*) FROM V_DONHANG
            UNION ALL SELECT 'V_CHITIETDONHANG', COUNT(*) FROM V_CHITIETDONHANG
            UNION ALL SELECT 'V_SANPHAM', COUNT(*) FROM V_SANPHAM
        `);
        const counts = {};
        for (const row of result.recordset) {
            counts[row.View] = row.Cnt;
        }
        res.json(counts);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// API: Đặt hàng cục bộ (gọi stored procedure trên S1)
app.post('/api/transaction/local', async (req, res) => {
    const { maKH, maSP, soLuong, maKho } = req.body;
    const log = [];
    const ts = () => new Date().toLocaleTimeString('vi-VN');

    try {
        const pool = pools.S1;
        if (!pool) throw new Error('S1 không khả dụng');

        const transaction = new sql.Transaction(pool);
        await transaction.begin();
        log.push({ ts: ts(), msg: 'BEGIN TRANSACTION tại S1', type: 'phase' });

        const request = new sql.Request(transaction);
        // Xin khóa ghi (UPDLOCK, HOLDLOCK)
        log.push({ ts: ts(), msg: `Xin khóa wl trên TONKHO (${maSP}, ${maKho})`, type: 'lock' });
        request.input('maSP', sql.VarChar, maSP);
        request.input('maKho', sql.VarChar, maKho);
        const lockResult = await request.query(
            'SELECT SoLuongTon FROM TONKHO WITH (UPDLOCK, HOLDLOCK) WHERE MaSP=@maSP AND MaKho=@maKho'
        );

        if (!lockResult.recordset.length || lockResult.recordset[0].SoLuongTon < soLuong) {
            await transaction.rollback();
            const ton = lockResult.recordset.length ? lockResult.recordset[0].SoLuongTon : 0;
            log.push({ ts: ts(), msg: `Tồn kho: ${ton} < ${soLuong} — KHÔNG ĐỦ`, type: 'err' });
            log.push({ ts: ts(), msg: 'ROLLBACK — giải phóng khóa', type: 'err' });
            return res.json({ success: false, log });
        }

        const tonCu = lockResult.recordset[0].SoLuongTon;
        log.push({ ts: ts(), msg: `Tồn kho: ${tonCu} ≥ ${soLuong} — đủ hàng` });

        // Trừ kho
        const req2 = new sql.Request(transaction);
        req2.input('soLuong', sql.Int, soLuong);
        req2.input('maSP', sql.VarChar, maSP);
        req2.input('maKho', sql.VarChar, maKho);
        await req2.query('UPDATE TONKHO SET SoLuongTon = SoLuongTon - @soLuong WHERE MaSP=@maSP AND MaKho=@maKho');
        log.push({ ts: ts(), msg: `UPDATE TONKHO: ${tonCu} → ${tonCu - soLuong}` });

        // Tạo đơn hàng
        const maDH = 'DH' + Date.now().toString(36).toUpperCase();
        const req3 = new sql.Request(transaction);
        req3.input('maDH', sql.VarChar, maDH);
        req3.input('maKH', sql.VarChar, maKH);
        await req3.query("INSERT INTO DONHANG (MaDH, MaKH, NgayLap, TrangThai) VALUES (@maDH, @maKH, GETDATE(), N'Đã xác nhận')");

        const req4 = new sql.Request(transaction);
        req4.input('maSP_sp', sql.VarChar, maSP);
        const spResult = await req4.query('SELECT GiaBan FROM SP_PUBLIC WHERE MaSP=@maSP_sp');
        const donGia = spResult.recordset[0].GiaBan;

        const req5 = new sql.Request(transaction);
        req5.input('maDH', sql.VarChar, maDH);
        req5.input('maSP', sql.VarChar, maSP);
        req5.input('maKho', sql.VarChar, maKho);
        req5.input('soLuong', sql.Int, soLuong);
        req5.input('donGia', sql.Decimal(18, 2), donGia);
        await req5.query('INSERT INTO CHITIETDONHANG VALUES (@maDH, @maSP, @maKho, @soLuong, @donGia)');
        log.push({ ts: ts(), msg: `INSERT đơn hàng ${maDH}` });

        await transaction.commit();
        log.push({ ts: ts(), msg: 'COMMIT — giải phóng toàn bộ khóa wl', type: 'ok' });
        res.json({ success: true, maDH, tonMoi: tonCu - soLuong, log });
    } catch (err) {
        log.push({ ts: ts(), msg: `LỖI: ${err.message}`, type: 'err' });
        res.json({ success: false, log });
    }
});

// API: Đặt hàng liên kho (gọi stored procedure 2PC trên S1)
app.post('/api/transaction/distributed', async (req, res) => {
    const { maKH, maSP, soLuong } = req.body;
    const log = [];
    const ts = () => new Date().toLocaleTimeString('vi-VN');

    try {
        const pool = pools.S1;
        if (!pool) throw new Error('S1 không khả dụng');

        log.push({ ts: ts(), msg: 'Gọi sp_DatHang_LienKho trên S1 (BEGIN DISTRIBUTED TRANSACTION)', type: 'phase' });

        const request = pool.request();
        request.input('MaKH', sql.VarChar, maKH);
        request.input('MaSP', sql.VarChar, maSP);
        request.input('TongSoLuong', sql.Int, soLuong);

        const result = await request.execute('sp_DatHang_LienKho');

        log.push({ ts: ts(), msg: 'sp_DatHang_LienKho hoàn tất', type: 'ok' });
        if (result.output) {
            log.push({ ts: ts(), msg: JSON.stringify(result.output), type: 'info' });
        }

        res.json({ success: true, log });
    } catch (err) {
        log.push({ ts: ts(), msg: `GLOBAL ABORT: ${err.message}`, type: 'err' });
        res.json({ success: false, log });
    }
});

// API: Reset dữ liệu demo
app.post('/api/reset', async (req, res) => {
    try {
        const pool = pools.S1;
        if (!pool) throw new Error('S1 không khả dụng');

        // Reset S1 local
        await pool.request().query(`
            UPDATE TONKHO SET SoLuongTon = 50  WHERE MaSP = 'SP001' AND MaKho = 'K001';
            UPDATE TONKHO SET SoLuongTon = 80  WHERE MaSP = 'SP002' AND MaKho = 'K001';
            UPDATE TONKHO SET SoLuongTon = 120 WHERE MaSP = 'SP003' AND MaKho = 'K001';
        `);

        // Reset S2 via Linked Server
        await pool.request().query(`
            UPDATE [S2_MT].[CSDLPT].[dbo].[TONKHO] SET SoLuongTon = 35 WHERE MaSP = 'SP001' AND MaKho = 'K004';
            UPDATE [S2_MT].[CSDLPT].[dbo].[TONKHO] SET SoLuongTon = 55 WHERE MaSP = 'SP002' AND MaKho = 'K004';
            UPDATE [S2_MT].[CSDLPT].[dbo].[TONKHO] SET SoLuongTon = 90 WHERE MaSP = 'SP003' AND MaKho = 'K004';
        `);

        // Delete demo orders
        await pool.request().query(`
            DELETE FROM CHITIETDONHANG WHERE MaDH LIKE 'DH26%';
            DELETE FROM DONHANG WHERE MaDH LIKE 'DH26%';
        `);

        res.json({ success: true, msg: 'Đã reset dữ liệu demo thành công' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// API: Reset đặc biệt cho demo 2PC
app.post('/api/reset-2pc', async (req, res) => {
    try {
        const pool = pools.S1;
        if (!pool) throw new Error('S1 không khả dụng');

        await pool.request().query(`
            UPDATE TONKHO SET SoLuongTon = 4 WHERE MaSP = 'SP001' AND MaKho = 'K001';
            UPDATE [S2_MT].[CSDLPT].[dbo].[TONKHO] SET SoLuongTon = 6 WHERE MaSP = 'SP001' AND MaKho = 'K004';
            DELETE FROM CHITIETDONHANG WHERE MaDH LIKE 'DH26%';
            DELETE FROM DONHANG WHERE MaDH LIKE 'DH26%';
        `);

        res.json({ success: true, msg: 'Reset 2PC: SP001@K001=4, SP001@K004=6' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ==================================================================
// KHỞI ĐỘNG
// ==================================================================
const PORT = 3000;

initPools().then(() => {
    app.listen(PORT, () => {
        console.log(`\n🌐 Server đang chạy tại http://localhost:${PORT}`);
        console.log('📡 Kết nối 3 SQL Server qua Radmin VPN');
        console.log('   S1: LAPTOP-M3FKU757 (Miền Bắc)');
        console.log('   S2: DESKTOP-Q5G45CD  (Miền Trung)');
        console.log('   S3: LAPTOP-UD52TRL3  (Miền Nam)\n');
    });
});

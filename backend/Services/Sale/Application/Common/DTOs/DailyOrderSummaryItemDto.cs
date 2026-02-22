namespace Sale.Application.Common.DTOs;

/// <summary>
///     One row of the daily order summary (tổng hợp đơn đặt hàng trong ngày).
///     Matches the UI table: STT, MÃ SP, TÊN SẢN PHẨM, QUY CÁCH, DANG (form), DANG (packaging), SỐ (quantity).
/// </summary>
public class DailyOrderSummaryItemDto
{
    /// <summary>STT - Số thứ tự</summary>
    public int Stt { get; set; }

    /// <summary>MÃ SP - Mã sản phẩm</summary>
    public string ProductCode { get; set; } = null!;

    /// <summary>TÊN SẢN PHẨM</summary>
    public string ProductName { get; set; } = null!;

    /// <summary>QUY CÁCH - Specification (e.g. 100gr, 250ml)</summary>
    public string Specification { get; set; } = null!;

    /// <summary>DANG - Dạng (form: Bột uống, Dung dịch, Hỗn dịch...)</summary>
    public string Form { get; set; } = null!;

    /// <summary>DANG - Đóng gói (Gói, Chai...)</summary>
    public string Packaging { get; set; } = null!;

    /// <summary>SỐ - Tổng số lượng đã đặt trong ngày</summary>
    public int TotalQuantity { get; set; }
}

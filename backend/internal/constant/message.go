package constant

// Auth
const (
	MsgEmailAlreadyExists      = "email already exists"
	MsgUsernameAlreadyExists   = "username already exists"
	MsgAuthFieldsRequired      = "username, email and password are required"
	MsgInvalidLoginCredentials = "invalid login or password"
)

// Password Reset
const (
	MsgPasswordResetEmailSent = "if that email address is in our system, you will receive a password reset link shortly"
	MsgPasswordResetSuccess   = "password has been reset successfully"
	MsgPasswordResetInvalid   = "invalid or expired password reset token"
	MsgTooManyRequests        = "too many requests, please try again later"
)

// User (admin / assign roles)
const (
	MsgUserNotFound = "user not found"
)

// Role
const (
	MsgRoleNameAlreadyExists = "role name already exists"
	MsgRoleCodeAlreadyExists = "role code already exists"
	MsgRoleNotFound          = "role not found"
	MsgInvalidRoleID         = "invalid role id"
)

// Permission
const (
	MsgPermissionCodeAlreadyExists = "permission code already exists"
	MsgPermissionNotFound          = "permission not found"
	MsgInvalidPermissionID         = "invalid permission id"
)

// Course
const (
	MsgCourseNotFound         = "course not found"
	MsgInvalidCourseID        = "invalid course id"
	MsgCourseSlugExists       = "course slug already exists"
	MsgSectionNotFound        = "section not found"
	MsgInvalidSectionID       = "invalid section id"
	MsgLessonNotFound         = "lesson not found"
	MsgInvalidLessonID        = "invalid lesson id"
	MsgInstructorNotFound     = "instructor not found"
	MsgInstructorRoleRequired = "user must have instructor role"
)

// Streaming / Classroom
const (
	MsgClassroomNotFound       = "classroom not found"
	MsgInvalidClassroomID      = "invalid classroom id"
	MsgClassroomRoomNameExists = "classroom room name already exists"
	MsgLiveKitConfigMissing    = "livekit api key/secret are not configured"
)

// Profile
const (
	MsgProfileNotFound  = "profile not found"
	MsgInvalidBirthDate = "invalid birth date"
	MsgInvalidProfile   = "invalid profile"
)

// Post / Comment / Reaction
const (
	MsgPostNotFound         = "post not found"
	MsgInvalidPostID        = "invalid post id"
	MsgPostForbidden        = "not authorized to modify this post"
	MsgPostContentRequired  = "post must have content or at least one image"
	MsgCommentNotFound      = "comment not found"
	MsgInvalidCommentID     = "invalid comment id"
	MsgCommentForbidden     = "not authorized to modify this comment"
	MsgCommentParentInvalid = "parent comment does not belong to this post"
)

// Reels
const (
	MsgReelNotFound = "reel not found"
)

// Customer (Sale)
const (
	MsgCustomerNameRequired    = "tên khách hàng là bắt buộc"
	MsgCustomerAddressRequired = "địa chỉ là bắt buộc"
	MsgCustomerPhoneRequired   = "số điện thoại là bắt buộc"
	MsgCustomerPhoneInvalid    = "số điện thoại không hợp lệ"
	MsgCustomerPhoneExists     = "Số điện thoại này đã tồn tại trong hệ thống. Vui lòng kiểm tra lại."
	MsgCustomerNotFound        = "khách hàng không tồn tại"
	MsgCustomerDeleteSuccess  = "xóa khách hàng thành công"
	MsgCustomerUpdateSuccess  = "cập nhật khách hàng thành công"
)

// Order (Sale)
const (
	MsgOrderCustomerHasOrderToday = "Khách hàng này đã có đơn hàng hôm nay"
	MsgOrderNotFound             = "đơn hàng không tồn tại"
	MsgOrderInvalidCustomer      = "thông tin khách hàng không hợp lệ"
	MsgOrderProductRequired      = "Vui lòng kiểm tra lại thông tin sản phẩm"
	MsgOrderQuantityInvalid      = "Số lượng sản phẩm không hợp lệ, vui lòng nhập lại số nguyên dương"
	MsgOrderSignFailed           = "Ký số không thành công, vui lòng kiểm tra lại thiết bị hoặc mã PIN"
	MsgOrderSaveSuccess          = "Lưu và ký đơn hàng thành công"
	MsgOrderServerError          = "Có lỗi xảy ra, vui lòng thử lại sau"
)

// Product (Sale)
const (
	MsgProductNotFound      = "sản phẩm không tồn tại"
	MsgProductCodeRequired  = "mã sản phẩm là bắt buộc"
	MsgProductNameRequired  = "tên sản phẩm là bắt buộc"
	MsgProductCodeExists    = "mã sản phẩm đã tồn tại"
	MsgProductSaveSuccess   = "lưu sản phẩm thành công"
	MsgProductDeleteSuccess = "xóa sản phẩm thành công"
	MsgProductServerError   = "có lỗi xảy ra, vui lòng thử lại sau"
)

// Order Summary (Bảng tổng hợp đơn hàng)
const (
	MsgOrderSummaryNotFound           = "bảng tổng hợp đơn không tồn tại"
	MsgOrderSummaryAlreadyExistsForDate = "đã có bảng tổng hợp đơn cho ngày này, mỗi ngày chỉ được một bảng"
	MsgOrderSummaryDateRequired       = "ngày tổng hợp đơn là bắt buộc"
	MsgOrderSummaryItemsRequired      = "bảng tổng hợp phải có ít nhất một sản phẩm"
	MsgOrderSummaryQuantityInvalid    = "số lượng sản phẩm không hợp lệ"
	MsgOrderSummaryServerError        = "có lỗi xảy ra, vui lòng thử lại sau"
	MsgOrderSummarySaveSuccess        = "lưu bảng tổng hợp đơn thành công"
	MsgOrderSummaryApproveSuccess     = "duyệt bảng tổng hợp đơn thành công"
)

// PIN (Security)
const (
	MsgPINRequired      = "mã PIN là bắt buộc"
	MsgPINInvalid       = "mã PIN phải gồm đúng 4 chữ số"
	MsgPINAlreadySet    = "mã PIN đã được thiết lập, vui lòng sử dụng chức năng đổi PIN"
	MsgPINNotSet        = "chưa thiết lập mã PIN, vui lòng thiết lập trước khi ký số"
	MsgPINIncorrect     = "mã PIN không đúng"
	MsgPINSetSuccess    = "thiết lập mã PIN thành công"
	MsgPINChangeSuccess = "đổi mã PIN thành công"
)

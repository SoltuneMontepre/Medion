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
	MsgProductNotFound = "sản phẩm không tồn tại"
)

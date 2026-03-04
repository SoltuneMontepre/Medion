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
	MsgRoleNotFound          = "role not found"
	MsgInvalidRoleID         = "invalid role id"
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

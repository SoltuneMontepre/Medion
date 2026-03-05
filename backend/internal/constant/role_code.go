package constant

// Role codes for role hierarchy (Role.ParentRoleID) and permissions.
//
// Two hierarchies in the system:
//  1. Role hierarchy: Role.ParentRoleID (e.g. sale_director -> sale_admin -> sale_person). Use for permission inheritance and UI.
//  2. Scoping: order list and order summary use these codes (sale_admin sees all sale_person orders and global summary).
const (
	// Sales hierarchy
	RoleCodeSaleDirector = "sale_director"
	RoleCodeSaleAdmin    = "sale_admin"
	RoleCodeSalePerson   = "sale_person"

	// Planning department
	RoleCodeKeHoachVien       = "ke_hoach_vien"
	RoleCodeTruongPhongKeHoach = "truong_phong_ke_hoach"

	// Warehouse
	RoleCodeKeToanKho      = "ke_toan_kho"
	RoleCodeQuanLyKho      = "quan_ly_kho"
	RoleCodeThuKhoThanhPham = "thu_kho_thanh_pham"
)

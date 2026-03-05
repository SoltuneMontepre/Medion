package constant

// HasAdminRole returns true if the user has the admin role (full bypass).
// Use this for "see all / do all" branches (e.g. list all orders, list all summaries).
func HasAdminRole(roleCodes []string) bool {
	for _, c := range roleCodes {
		if c == RoleCodeAdmin {
			return true
		}
	}
	return false
}

// HasRoleOrAdmin returns true if the user has the given role or has the admin role.
// Use this for any permission check (e.g. "can submit plan", "can approve dispatch").
// When you add new features, use only this and admin bypass is automatic.
func HasRoleOrAdmin(roleCodes []string, roleCode string) bool {
	for _, c := range roleCodes {
		if c == RoleCodeAdmin || c == roleCode {
			return true
		}
	}
	return false
}

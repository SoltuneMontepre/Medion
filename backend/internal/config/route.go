package config

import (
	"net/http"

	"backend/internal/controller"

	"github.com/go-fuego/fuego"
)

func RegisterRoutes(server *fuego.Server, authController *controller.AuthController, customerController *controller.CustomerController, productController *controller.ProductController, ingredientController *controller.IngredientController, orderController *controller.OrderController, orderSummaryController *controller.OrderSummaryController, pinController *controller.PINController, roleController *controller.RoleController, userController *controller.UserController, companyController *controller.CompanyController, departmentController *controller.DepartmentController, inventoryController *controller.InventoryController, productionPlanController *controller.ProductionPlanController, productionOrderController *controller.ProductionOrderController, finishedProductDispatchController *controller.FinishedProductDispatchController, authGuardMiddleware func(next http.Handler) http.Handler) {
	authGroup := fuego.Group(server, "/api/v1")

	fuego.Post(authGroup, "/register", authController.Register,
		fuego.OptionSummary("Register user"),
		fuego.OptionTags("Authentication"),
	)

	fuego.Post(authGroup, "/login", authController.Login,
		fuego.OptionSummary("Login user"),
		fuego.OptionTags("Authentication"),
	)

	fuego.Post(authGroup, "/refresh", authController.Refresh,
		fuego.OptionSummary("Refresh access token"),
		fuego.OptionTags("Authentication"),
	)

	fuego.Post(authGroup, "/logout", authController.Logout,
		fuego.OptionSummary("Logout user"),
		fuego.OptionTags("Authentication"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	fuego.Get(authGroup, "/me", authController.Me,
		fuego.OptionSummary("Get current user"),
		fuego.OptionTags("Authentication"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	// Sale: customers, products, orders (protected by auth for GMP traceability)
	saleGroup := fuego.Group(authGroup, "/sale")
	fuego.Get(saleGroup, "/customers", customerController.List,
		fuego.OptionSummary("List customers"),
		fuego.OptionTags("Customers"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/customers/suggest", customerController.Suggest,
		fuego.OptionSummary("Suggest customers by code/name/phone"),
		fuego.OptionTags("Customers"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/customers/{id}", customerController.GetByID,
		fuego.OptionSummary("Get customer by ID"),
		fuego.OptionTags("Customers"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(saleGroup, "/customers", customerController.Create,
		fuego.OptionSummary("Create customer"),
		fuego.OptionTags("Customers"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(saleGroup, "/customers/{id}", customerController.Update,
		fuego.OptionSummary("Update customer"),
		fuego.OptionTags("Customers"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Delete(saleGroup, "/customers/{id}", customerController.Delete,
		fuego.OptionSummary("Delete customer"),
		fuego.OptionTags("Customers"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/products", productController.List,
		fuego.OptionSummary("List products"),
		fuego.OptionTags("Products"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/products/suggest", productController.Suggest,
		fuego.OptionSummary("Suggest products by code/name"),
		fuego.OptionTags("Products"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/products/{id}", productController.GetByID,
		fuego.OptionSummary("Get product by id"),
		fuego.OptionTags("Products"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(saleGroup, "/products", productController.Create,
		fuego.OptionSummary("Create product"),
		fuego.OptionTags("Products"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(saleGroup, "/products/{id}", productController.Update,
		fuego.OptionSummary("Update product"),
		fuego.OptionTags("Products"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Delete(saleGroup, "/products/{id}", productController.Delete,
		fuego.OptionSummary("Delete product"),
		fuego.OptionTags("Products"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	// Ingredients (Nguyên liệu) — CRUD for raw materials master data
	ingGroup := fuego.Group(authGroup, "/ingredients")
	fuego.Get(ingGroup, "", ingredientController.List,
		fuego.OptionSummary("List ingredients (nguyên liệu)"),
		fuego.OptionTags("Ingredients"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(ingGroup, "/suggest", ingredientController.Suggest,
		fuego.OptionSummary("Suggest ingredients by code/name"),
		fuego.OptionTags("Ingredients"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(ingGroup, "/{id}", ingredientController.GetByID,
		fuego.OptionSummary("Get ingredient by id"),
		fuego.OptionTags("Ingredients"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(ingGroup, "", ingredientController.Create,
		fuego.OptionSummary("Create ingredient"),
		fuego.OptionTags("Ingredients"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(ingGroup, "/{id}", ingredientController.Update,
		fuego.OptionSummary("Update ingredient"),
		fuego.OptionTags("Ingredients"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Delete(ingGroup, "/{id}", ingredientController.Delete,
		fuego.OptionSummary("Delete ingredient"),
		fuego.OptionTags("Ingredients"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/orders", orderController.List,
		fuego.OptionSummary("List orders"),
		fuego.OptionTags("Orders"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/orders/check-today", orderController.CheckCustomerOrderToday,
		fuego.OptionSummary("Check if customer has order today and get next order number"),
		fuego.OptionTags("Orders"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(saleGroup, "/orders", orderController.Create,
		fuego.OptionSummary("Create and sign order"),
		fuego.OptionTags("Orders"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/orders/{id}", orderController.GetByID,
		fuego.OptionSummary("Get order by id"),
		fuego.OptionTags("Orders"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	// Order summary (Bảng tổng hợp đơn hàng) — read-only; each sale admin sees only their own (OwnerID)
	fuego.Get(saleGroup, "/order-summaries", orderSummaryController.List,
		fuego.OptionSummary("List order summaries for current sale admin"),
		fuego.OptionTags("Order Summaries"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/order-summaries/by-date", orderSummaryController.GetByDate,
		fuego.OptionSummary("Get order summary by date (e.g. today) for current sale admin"),
		fuego.OptionTags("Order Summaries"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(saleGroup, "/order-summaries/{id}", orderSummaryController.GetByID,
		fuego.OptionSummary("Get order summary by id"),
		fuego.OptionTags("Order Summaries"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	// PIN management (digital signing credential)
	pinGroup := fuego.Group(authGroup, "/pin")
	fuego.Get(pinGroup, "", pinController.Status,
		fuego.OptionSummary("Get PIN status"),
		fuego.OptionTags("PIN"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(pinGroup, "", pinController.Set,
		fuego.OptionSummary("Set PIN (first time)"),
		fuego.OptionTags("PIN"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(pinGroup, "", pinController.Change,
		fuego.OptionSummary("Change PIN"),
		fuego.OptionTags("PIN"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(pinGroup, "/verify", pinController.Verify,
		fuego.OptionSummary("Verify PIN"),
		fuego.OptionTags("PIN"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	// Roles: CRUD and hierarchy (parent role)
	roleGroup := fuego.Group(authGroup, "/roles")
	fuego.Get(roleGroup, "", roleController.List,
		fuego.OptionSummary("List roles (paginated)"),
		fuego.OptionTags("Roles"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(roleGroup, "/all", roleController.ListAll,
		fuego.OptionSummary("List all roles for hierarchy"),
		fuego.OptionTags("Roles"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(roleGroup, "/{id}", roleController.GetByID,
		fuego.OptionSummary("Get role by id"),
		fuego.OptionTags("Roles"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(roleGroup, "", roleController.Create,
		fuego.OptionSummary("Create role"),
		fuego.OptionTags("Roles"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(roleGroup, "/{id}", roleController.Update,
		fuego.OptionSummary("Update role"),
		fuego.OptionTags("Roles"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Delete(roleGroup, "/{id}", roleController.Delete,
		fuego.OptionSummary("Delete role"),
		fuego.OptionTags("Roles"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	// Users: list and assign roles (admin / HR)
	userGroup := fuego.Group(authGroup, "/users")
	fuego.Get(userGroup, "", userController.List,
		fuego.OptionSummary("List users (paginated)"),
		fuego.OptionTags("Users"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(userGroup, "/{id}/roles", userController.GetUserRoles,
		fuego.OptionSummary("Get roles assigned to user"),
		fuego.OptionTags("Users"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(userGroup, "/{id}/roles", userController.SetUserRoles,
		fuego.OptionSummary("Set user roles (replace all)"),
		fuego.OptionTags("Users"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(userGroup, "/{id}/supervisor", userController.SetSupervisor,
		fuego.OptionSummary("Set user's direct leader (supervisor); pass null to clear"),
		fuego.OptionTags("Users"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(userGroup, "/{id}/department", userController.SetDepartment,
		fuego.OptionSummary("Set user's department; pass null to clear"),
		fuego.OptionTags("Users"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	// Company & Departments (org structure)
	companyGroup := fuego.Group(authGroup, "/companies")
	fuego.Get(companyGroup, "", companyController.List,
		fuego.OptionSummary("List companies (for dropdown)"),
		fuego.OptionTags("Companies"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	deptGroup := fuego.Group(authGroup, "/departments")
	fuego.Get(deptGroup, "", departmentController.List,
		fuego.OptionSummary("List departments (paginated, optional companyId filter)"),
		fuego.OptionTags("Departments"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(deptGroup, "/suggest", departmentController.Suggest,
		fuego.OptionSummary("Suggest departments by companyId and/or q"),
		fuego.OptionTags("Departments"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(deptGroup, "/{id}", departmentController.GetByID,
		fuego.OptionSummary("Get department by id"),
		fuego.OptionTags("Departments"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(deptGroup, "", departmentController.Create,
		fuego.OptionSummary("Create department"),
		fuego.OptionTags("Departments"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(deptGroup, "/{id}", departmentController.Update,
		fuego.OptionSummary("Update department"),
		fuego.OptionTags("Departments"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Delete(deptGroup, "/{id}", departmentController.Delete,
		fuego.OptionSummary("Delete department"),
		fuego.OptionTags("Departments"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	// Inventory (Tồn kho): list by warehouse type (raw | semi | finished), get by id
	invGroup := fuego.Group(authGroup, "/inventory")
	fuego.Get(invGroup, "", inventoryController.List,
		fuego.OptionSummary("List inventory (tồn kho) by warehouse type"),
		fuego.OptionTags("Inventory"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(invGroup, "/{id}", inventoryController.GetByID,
		fuego.OptionSummary("Get inventory record by id"),
		fuego.OptionTags("Inventory"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	// Production plan (Bảng kế hoạch sản xuất theo ngày)
	planGroup := fuego.Group(authGroup, "/production-plans")
	fuego.Get(planGroup, "/by-date", productionPlanController.GetByDate,
		fuego.OptionSummary("Get production plan by date (query: date=YYYY-MM-DD)"),
		fuego.OptionTags("Production Plan"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(planGroup, "/{id}", productionPlanController.GetByID,
		fuego.OptionSummary("Get production plan by id"),
		fuego.OptionTags("Production Plan"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(planGroup, "", productionPlanController.Create,
		fuego.OptionSummary("Create production plan"),
		fuego.OptionTags("Production Plan"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(planGroup, "/{id}", productionPlanController.Update,
		fuego.OptionSummary("Update production plan"),
		fuego.OptionTags("Production Plan"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(planGroup, "/{id}/submit", productionPlanController.Submit,
		fuego.OptionSummary("Submit production plan (draft -> submitted)"),
		fuego.OptionTags("Production Plan"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(planGroup, "/{id}/approve", productionPlanController.Approve,
		fuego.OptionSummary("Approve production plan (submitted -> approved)"),
		fuego.OptionTags("Production Plan"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(planGroup, "/{id}/reject", productionPlanController.Reject,
		fuego.OptionSummary("Reject production plan (submitted -> draft)"),
		fuego.OptionTags("Production Plan"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	// Production order (Lệnh sản xuất) — 1 order = 1 product
	orderGroup := fuego.Group(authGroup, "/production-orders")
	fuego.Get(orderGroup, "", productionOrderController.List,
		fuego.OptionSummary("List production orders (query: status, limit, offset)"),
		fuego.OptionTags("Production Order"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(orderGroup, "/{id}", productionOrderController.GetByID,
		fuego.OptionSummary("Get production order by id"),
		fuego.OptionTags("Production Order"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(orderGroup, "", productionOrderController.Create,
		fuego.OptionSummary("Create production order (1 product per order)"),
		fuego.OptionTags("Production Order"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(orderGroup, "/{id}", productionOrderController.Update,
		fuego.OptionSummary("Update draft production order"),
		fuego.OptionTags("Production Order"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)

	// Finished product dispatch (Phiếu xuất kho Thành phẩm)
	dispatchGroup := fuego.Group(authGroup, "/finished-product-dispatches")
	fuego.Get(dispatchGroup, "", finishedProductDispatchController.List,
		fuego.OptionSummary("List phiếu xuất kho thành phẩm (query: status, limit, offset)"),
		fuego.OptionTags("Phiếu xuất kho TP"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Get(dispatchGroup, "/{id}", finishedProductDispatchController.GetByID,
		fuego.OptionSummary("Get phiếu xuất kho thành phẩm by id"),
		fuego.OptionTags("Phiếu xuất kho TP"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(dispatchGroup, "", finishedProductDispatchController.Create,
		fuego.OptionSummary("Create phiếu xuất kho thành phẩm (draft)"),
		fuego.OptionTags("Phiếu xuất kho TP"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Put(dispatchGroup, "/{id}", finishedProductDispatchController.Update,
		fuego.OptionSummary("Update phiếu xuất kho (draft or revision_requested)"),
		fuego.OptionTags("Phiếu xuất kho TP"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(dispatchGroup, "/{id}/submit", finishedProductDispatchController.Submit,
		fuego.OptionSummary("Submit for approval (draft/revision_requested -> pending_approval)"),
		fuego.OptionTags("Phiếu xuất kho TP"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(dispatchGroup, "/{id}/approve", finishedProductDispatchController.Approve,
		fuego.OptionSummary("Approve phiếu xuất kho (Quản lý kho)"),
		fuego.OptionTags("Phiếu xuất kho TP"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
	fuego.Post(dispatchGroup, "/{id}/reject", finishedProductDispatchController.Reject,
		fuego.OptionSummary("Reject / yêu cầu sửa (Quản lý kho)"),
		fuego.OptionTags("Phiếu xuất kho TP"),
		fuego.OptionMiddleware(authGuardMiddleware),
	)
}

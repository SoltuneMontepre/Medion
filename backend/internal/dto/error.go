package dto

type AppError struct {
	HTTPStatus int
	Code       int
	Message    string
	Err        error
}

func (e *AppError) Error() string {
	if e == nil {
		return "unknown error"
	}
	if e.Message != "" {
		return e.Message
	}
	if e.Err != nil {
		return e.Err.Error()
	}
	return "unknown error"
}

func (e *AppError) Unwrap() error {
	if e == nil {
		return nil
	}
	return e.Err
}

func (e *AppError) StatusCode() int {
	if e == nil || e.HTTPStatus == 0 {
		return 500
	}
	return e.HTTPStatus
}

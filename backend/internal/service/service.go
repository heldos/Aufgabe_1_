package service

import (
	"context"

	tempconvv1 "tempconv/backend/gen/tempconv/v1"
)

type Service struct {
	tempconvv1.UnimplementedTempConvServiceServer
}

func New() *Service {
	return &Service{}
}

func (s *Service) CelsiusToFahrenheit(ctx context.Context, req *tempconvv1.CelsiusToFahrenheitRequest) (*tempconvv1.CelsiusToFahrenheitResponse, error) {
	f := (req.GetCelsius() * 9.0 / 5.0) + 32.0
	return &tempconvv1.CelsiusToFahrenheitResponse{Fahrenheit: f}, nil
}

func (s *Service) FahrenheitToCelsius(ctx context.Context, req *tempconvv1.FahrenheitToCelsiusRequest) (*tempconvv1.FahrenheitToCelsiusResponse, error) {
	c := (req.GetFahrenheit() - 32.0) * 5.0 / 9.0
	return &tempconvv1.FahrenheitToCelsiusResponse{Celsius: c}, nil
}


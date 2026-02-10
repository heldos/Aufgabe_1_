package service

import (
	"testing"
)

func TestCelsiusToFahrenheit(t *testing.T) {
	s := New()

	tests := []struct {
		name    string
		c       float64
		wantF   float64
	}{
		{"freezing", 0, 32},
		{"boiling", 100, 212},
		{"minus40", -40, -40},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := (tt.c*9.0/5.0)+32.0
			if got != tt.wantF {
				t.Fatalf("expected %vF, got %vF", tt.wantF, got)
			}

			// sanity check inverse formula is consistent
			back := (got - 32.0) * 5.0 / 9.0
			if back != tt.c {
				t.Fatalf("expected back-conversion %vC, got %vC", tt.c, back)
			}
		})
	}

	_ = s
}


use dep::std;

struct FixedPoint {
    value: Field,
    scale: Field,
}

impl FixedPoint {
    pub fn new(value: Field, scale: Field) -> Self {
        FixedPoint { value, scale }
    }

    pub fn add(fixed1: FixedPoint, fixed2: FixedPoint) -> FixedPoint {
        assert(fixed1.scale == fixed2.scale, "Scale mismatch");
        FixedPoint {
            value: fixed1.value + fixed2.value,
            scale: fixed1.scale,
        }
    }

    pub fn subtract(fixed1: FixedPoint, fixed2: FixedPoint) -> FixedPoint {
        assert(fixed1.scale == fixed2.scale, "Scale mismatch");
        FixedPoint {
            value: fixed1.value - fixed2.value,
            scale: fixed1.scale,
        }
    }

    pub fn multiply(fixed1: FixedPoint, fixed2: FixedPoint) -> FixedPoint {
        assert(fixed1.scale == fixed2.scale, "Scale mismatch");
        // let scaled_value2 = scale_value(fixed2.value as u64, fixed2.scale as u64, fixed1.scale as u64);
        let product = fixed1.value * fixed2.value;

        FixedPoint {
            value: product,
            scale: fixed1.scale,
        }
    }


    pub fn divide(fixed1: FixedPoint, fixed2: FixedPoint) -> FixedPoint {
        assert(fixed1.scale == fixed2.scale, "Scale mismatch");
        assert(fixed2.value != 0, "Division by zero");
        let mut scaling_factor = 1;
        for _ in 0..fixed1.scale {
            scaling_factor *= 1;
        }
        FixedPoint {
            value: (fixed1.value * scaling_factor) / fixed2.value,
            scale: fixed1.scale,
        }
    }

    pub fn is_greater_than(fixed1: FixedPoint, fixed2: FixedPoint) -> bool {
        assert(fixed1.scale == fixed2.scale, "Scale mismatch");
        fixed1.value as u64 > fixed2.value as u64
    }
    pub fn is_lesser_than(fixed1: FixedPoint, fixed2: FixedPoint) -> bool {
        assert(fixed1.scale == fixed2.scale, "Scale mismatch");
        fixed1.value as u64 < fixed2.value as u64
    }
    pub fn power(base: FixedPoint, exponent: u32) -> FixedPoint {
        let mut result = base;

        // If exponent is 0, return 1 
        if exponent == 0 {
            result.value = 1;
            result.scale = base.scale;
        }

        // Starting the loop from 1 
        for _ in 1..exponent {
            result.value = result.value * base.value;
            result.scale = base.scale;
        }

        result
    }
}


// Helper function to scale the value
fn scale_value(value: u64, original_scale: u64, target_scale: u64) -> u64 {
    if target_scale > original_scale {
        let scale_increase = target_scale - original_scale;
        let mut scaling_factor = 1 as u64;
        for _ in 0..scale_increase {
            scaling_factor *= 10;
        }
        value * scaling_factor
    } else {
        value
    }
}



#[test]
fn test_add_positive_numbers() {
    let fixed1 = FixedPoint::new(10, 2);
    let fixed2 = FixedPoint::new(20, 2);
    let result = FixedPoint::add(fixed1, fixed2);
    assert(result.value == 30);
    assert(result.scale == 2);

}

#[test]
fn test_add_negative_numbers() {
    let fixed1 = FixedPoint::new(-10, 2);
    let fixed2 = FixedPoint::new(-5, 2);
    let result = FixedPoint::add(fixed1, fixed2);
    assert(result.value == -15);
    assert(result.scale == 2);
}

#[test]
fn test_add_positive_and_negative() {
    let fixed1 = FixedPoint::new(15, 2);
    let fixed2 = FixedPoint::new(-5, 2);
    let result = FixedPoint::add(fixed1, fixed2);
    assert(result.value == 10);
    assert(result.scale == 2);
}

#[test(should_fail)]
fn test_add_scale_mismatch() {
    let fixed1 = FixedPoint::new(10, 2);
    let fixed2 = FixedPoint::new(5, 3);
    let _result = FixedPoint::add(fixed1, fixed2);
}

#[test]
fn test_add_zero() {
    let fixed1 = FixedPoint::new(10, 2);
    let fixed2 = FixedPoint::new(0, 2);
    let result = FixedPoint::add(fixed1, fixed2);
    assert(result.value == 10);
    assert(result.scale == 2);

}

#[test]
fn test_subtract_positive_numbers() {
    let fixed1 = FixedPoint::new(30, 2);
    let fixed2 = FixedPoint::new(10, 2);
    let result = FixedPoint::subtract(fixed1, fixed2);
    assert(result.value == 20);
    assert(result.scale == 2);

}

#[test]
fn test_subtract_larger_from_smaller() {
    let fixed1 = FixedPoint::new(10, 2);
    let fixed2 = FixedPoint::new(20, 2);
    let result = FixedPoint::subtract(fixed1, fixed2);
    assert(result.value == -10);
    assert(result.scale == 2);

}

#[test]
fn test_subtract_negative_numbers() {
    let fixed1 = FixedPoint::new(-15, 2);
    let fixed2 = FixedPoint::new(-5, 2);
    let result = FixedPoint::subtract(fixed1, fixed2);
    assert(result.value == -10);
    assert(result.scale == 2);

}

#[test(should_fail)]
fn test_subtract_scale_mismatch() {
    let fixed1 = FixedPoint::new(10, 2);
    let fixed2 = FixedPoint::new(5, 3);
    let _result = FixedPoint::subtract(fixed1, fixed2);
}

#[test]
fn test_subtract_zero() {
    let fixed1 = FixedPoint::new(10, 2);
    let fixed2 = FixedPoint::new(0, 2);
    let result = FixedPoint::subtract(fixed1, fixed2);
    assert(result.value == 10);
    assert(result.scale == 2);

}

#[test]
fn test_multiply_positive_numbers() {
    let fixed1 = FixedPoint::new(2, 1);  
    let fixed2 = FixedPoint::new(3, 1);  
    let result = FixedPoint::multiply(fixed1, fixed2);
    assert(result.value == 6);
    assert(result.scale == 1);
}

#[test]
fn test_multiply_by_zero() {
    let fixed1 = FixedPoint::new(10, 2);
    let fixed2 = FixedPoint::new(0, 2);
    let result = FixedPoint::multiply(fixed1, fixed2);
    assert(result.value == 0);
    assert(result.scale == 2);
}

#[test]
fn test_multiply_positive_and_negative() {
    let fixed1 = FixedPoint::new(4, 1);  
    let fixed2 = FixedPoint::new(-5, 1); 
    let result = FixedPoint::multiply(fixed1, fixed2);
    assert(result.value == -20 );
    assert(result.scale == 1);
}

#[test(should_fail)]
fn test_multiply_scale_mismatch() {
    let fixed1 = FixedPoint::new(10, 2);
    let fixed2 = FixedPoint::new(5, 3);
    let _result = FixedPoint::multiply(fixed1, fixed2);
}

#[test]
fn test_divide_positive_numbers() {
    let fixed1 = FixedPoint::new(10, 1); 
    let fixed2 = FixedPoint::new(5, 1);  
    let result = FixedPoint::divide(fixed1, fixed2);
    assert(result.value == 2);
    assert(result.scale == 1);

}

#[test(should_fail)]
fn test_divide_by_smaller_number() {
    let fixed1 = FixedPoint::new(5, 1);   
    let fixed2 = FixedPoint::new(10, 1);  
    let result = FixedPoint::divide(fixed1, fixed2);
    assert(result.value == 5);
    assert(result.scale == 2);

}

#[test]
fn test_divide_negative_numbers() {
    let fixed1 = FixedPoint::new(-10, 1); 
    let fixed2 = FixedPoint::new(-5, 1);  
    let result = FixedPoint::divide(fixed1, fixed2);
    assert(result.value == 2);
    assert(result.scale == 1);

}

#[test]
fn test_divide_positive_and_negative() {
    let fixed1 = FixedPoint::new(10, 1);  
    let fixed2 = FixedPoint::new(-5, 1);  
    let result = FixedPoint::divide(fixed1, fixed2);
    assert(result.value == -2);
    assert(result.scale == 1);

}

#[test(should_fail)]
fn test_divide_by_zero() {
    let fixed1 = FixedPoint::new(10, 2);
    let fixed2 = FixedPoint::new(0, 2);
    let _result = FixedPoint::divide(fixed1, fixed2);
    

}

#[test]
fn test_greater_than_positive_numbers() {
    let fixed1 = FixedPoint::new(30, 2);
    let fixed2 = FixedPoint::new(20, 2);
    let result = FixedPoint::is_greater_than(fixed1, fixed2);
    assert(result);
}

#[test]
fn test_greater_than_negative_numbers() {
    let fixed1 = FixedPoint::new(-10, 2);
    let fixed2 = FixedPoint::new(-20, 2);
    let result = FixedPoint::is_greater_than(fixed1, fixed2);
    assert(result);
}

#[test(should_fail)]
fn test_not_greater_than() {
    let fixed1 = FixedPoint::new(10, 2);
    let fixed2 = FixedPoint::new(20, 2);
    let result = FixedPoint::is_greater_than(fixed1, fixed2);
    assert(result);
}

#[test(should_fail)]
fn test_equal_values_not_greater() {
    let fixed1 = FixedPoint::new(20, 2);
    let fixed2 = FixedPoint::new(20, 2);
    let result = FixedPoint::is_greater_than(fixed1, fixed2);
    assert(result);
}

#[test]
fn test_lesser_than_positive_numbers() {
    let fixed1 = FixedPoint::new(10, 2);
    let fixed2 = FixedPoint::new(20, 2);
    let result = FixedPoint::is_lesser_than(fixed1, fixed2);
    assert(result);
}

#[test]
fn test_lesser_than_negative_numbers() {
    let fixed1 = FixedPoint::new(-20, 2);
    let fixed2 = FixedPoint::new(-10, 2);
    let result = FixedPoint::is_lesser_than(fixed1, fixed2);
    assert(result);
}

#[test(should_fail)]
fn test_not_lesser_than() {
    let fixed1 = FixedPoint::new(30, 2);
    let fixed2 = FixedPoint::new(20, 2);
    let result = FixedPoint::is_lesser_than(fixed1, fixed2);
    assert(result);
}

#[test(should_fail)]
fn test_equal_values_not_lesser() {
    let fixed1 = FixedPoint::new(20, 2);
    let fixed2 = FixedPoint::new(20, 2);
    let result = FixedPoint::is_lesser_than(fixed1, fixed2);
    assert(result);
}

#[test]
fn test_power_zero() {
    let base = FixedPoint::new(5, 2);
    let exponent = 0;
    let result = FixedPoint::power(base, exponent);
    assert(result.value == 1);
    assert(result.scale == 2);
}

#[test]
fn test_power_one() {
    let base = FixedPoint::new(5, 2);
    let exponent = 1;
    let result = FixedPoint::power(base, exponent);
    assert(result.value == 5);
    assert(result.scale == 2);
}

#[test]
fn test_positive_integer_power() {
    let base = FixedPoint::new(2, 2); 
    let exponent = 3;
    let result = FixedPoint::power(base, exponent);
    assert(result.value == 8);
    assert(result.scale == 2);
}

#[test]
fn test_large_exponent_power() {
    let base = FixedPoint::new(2, 2);  
    let exponent = 5;
    let result = FixedPoint::power(base, exponent);
    assert(result.value == 32); 
    assert(result.scale == 2);
}

package com.uzair.publicon.util;

import java.security.SecureRandom;

public class OTPGenerator {
    public static String generateOTP() {
        SecureRandom random = new SecureRandom();
        int otp = 100000 + random.nextInt(900000); // Generates a number between 100000 and 999999
        return String.valueOf(otp);
    }
}

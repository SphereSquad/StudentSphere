
package com.studentsphere.common;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class PasswordUtil {

    public static String hashPassword(String password) {
        try {
            byte[] salt = new byte[16];
            new SecureRandom().nextBytes(salt);

            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt);

            byte[] hash = md.digest(
                    password.getBytes(StandardCharsets.UTF_8));

            return Base64.getEncoder().encodeToString(salt)
                    + ":"
                    + Base64.getEncoder().encodeToString(hash);

        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(
                    "Password hashing failed.", e);
        }
    }

    public static boolean verifyPassword(
            String password, String storedValue) {
        try {
            String[] parts = storedValue.split(":");

            if (parts.length != 2) {
                return false;
            }

            byte[] salt = Base64.getDecoder().decode(parts[0]);
            byte[] expectedHash = Base64.getDecoder().decode(parts[1]);

            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt);

            byte[] actualHash = md.digest(
                    password.getBytes(StandardCharsets.UTF_8));

            return MessageDigest.isEqual(expectedHash, actualHash);

        } catch (IllegalArgumentException | NoSuchAlgorithmException e) {
            return false;
        }
    }
}

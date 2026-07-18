package com.forge.common.exception;

/** Thrown on login with a wrong email/password, and on an invalid/expired/revoked refresh token. Mapped to 401. */
public class InvalidCredentialsException extends RuntimeException {
    public InvalidCredentialsException(String message) {
        super(message);
    }
}

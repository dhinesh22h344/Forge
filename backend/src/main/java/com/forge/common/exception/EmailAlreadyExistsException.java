package com.forge.common.exception;

/** Thrown on registration when the email is already taken. Mapped to 409. */
public class EmailAlreadyExistsException extends RuntimeException {
    public EmailAlreadyExistsException(String email) {
        super("Email already registered: " + email);
    }
}

package com.forge.common.exception;

import java.time.Instant;
import java.util.List;

/** Wire shape for every error response — matches docs/api/openapi.yaml `Error` schema. */
public record ErrorResponse(
        Instant timestamp, int status, String error, String message, String path, List<FieldError> fieldErrors) {

    public record FieldError(String field, String message) {}

    public static ErrorResponse of(int status, String error, String message, String path) {
        return new ErrorResponse(Instant.now(), status, error, message, path, List.of());
    }

    public static ErrorResponse withFieldErrors(
            int status, String error, String message, String path, List<FieldError> fieldErrors) {
        return new ErrorResponse(Instant.now(), status, error, message, path, fieldErrors);
    }
}

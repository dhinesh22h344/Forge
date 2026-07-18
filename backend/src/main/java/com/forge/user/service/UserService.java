package com.forge.user.service;

import com.forge.auth.dto.UpdateProfileRequest;
import com.forge.auth.dto.UserResponse;
import com.forge.auth.service.AuthService;
import com.forge.auth.service.RefreshTokenService;
import com.forge.common.exception.InvalidCredentialsException;
import com.forge.common.validation.SecurityUtils;
import com.forge.user.dto.ChangePasswordRequest;
import com.forge.user.entity.User;
import com.forge.user.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class UserService {

    private final UserRepository userRepository;
    private final AuthService authService;
    private final RefreshTokenService refreshTokenService;
    private final PasswordEncoder passwordEncoder;

    public UserService(
            UserRepository userRepository,
            AuthService authService,
            RefreshTokenService refreshTokenService,
            PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.authService = authService;
        this.refreshTokenService = refreshTokenService;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional(readOnly = true)
    public UserResponse getCurrentUser() {
        return authService.toResponse(findCurrent());
    }

    public UserResponse updateProfile(UpdateProfileRequest request) {
        User user = findCurrent();
        if (request.profilePictureUrl() != null) user.setProfilePictureUrl(request.profilePictureUrl());
        if (request.timezone() != null) user.setTimezone(request.timezone());
        if (request.country() != null) user.setCountry(request.country());
        if (request.language() != null) user.setLanguage(request.language());
        if (request.darkModePreference() != null) user.setDarkModePreference(request.darkModePreference());
        if (request.bio() != null) user.setBio(request.bio());
        return authService.toResponse(user);
    }

    public void changePassword(ChangePasswordRequest request) {
        User user = findCurrent();
        if (user.getPasswordHash() == null || !passwordEncoder.matches(request.currentPassword(), user.getPasswordHash())) {
            throw new InvalidCredentialsException("Current password is incorrect");
        }
        user.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        // Force re-login everywhere else — an attacker with a live session
        // shouldn't be able to ride it out after the legitimate owner
        // changes their password.
        refreshTokenService.revokeAllForUser(user.getId());
    }

    public void deleteAccount() {
        User user = findCurrent();
        refreshTokenService.revokeAllForUser(user.getId());
        user.tombstone();
        userRepository.delete(user);
    }

    private User findCurrent() {
        return userRepository.findById(SecurityUtils.getCurrentUserId()).orElseThrow();
    }
}

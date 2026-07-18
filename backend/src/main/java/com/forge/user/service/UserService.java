package com.forge.user.service;

import com.forge.auth.dto.UpdateProfileRequest;
import com.forge.auth.dto.UserResponse;
import com.forge.auth.service.AuthService;
import com.forge.common.validation.SecurityUtils;
import com.forge.user.entity.User;
import com.forge.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class UserService {

    private final UserRepository userRepository;
    private final AuthService authService;

    public UserService(UserRepository userRepository, AuthService authService) {
        this.userRepository = userRepository;
        this.authService = authService;
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

    private User findCurrent() {
        return userRepository.findById(SecurityUtils.getCurrentUserId()).orElseThrow();
    }
}

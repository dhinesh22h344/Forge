package com.forge.auth.service;

import com.forge.auth.dto.AuthResponse;
import com.forge.auth.dto.LoginRequest;
import com.forge.auth.dto.RegisterRequest;
import com.forge.auth.dto.UserResponse;
import com.forge.common.exception.EmailAlreadyExistsException;
import com.forge.common.exception.InvalidCredentialsException;
import com.forge.habitlog.dto.StreakResponse;
import com.forge.habitlog.service.StreakService;
import com.forge.security.jwt.JwtService;
import com.forge.user.entity.User;
import com.forge.user.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;
    private final StreakService streakService;

    public AuthService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            RefreshTokenService refreshTokenService,
            StreakService streakService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.refreshTokenService = refreshTokenService;
        this.streakService = streakService;
    }

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmailIgnoreCase(request.email())) {
            throw new EmailAlreadyExistsException(request.email());
        }
        if (userRepository.existsByUsernameIgnoreCase(request.username())) {
            throw new IllegalArgumentException("Username already taken: " + request.username());
        }
        User user = new User(
                request.username(),
                request.email(),
                passwordEncoder.encode(request.password()),
                request.timezone(),
                request.country(),
                request.language(),
                request.darkModePreference());
        user = userRepository.save(user);
        return issueTokens(user);
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        User user = userRepository
                .findByEmailIgnoreCase(request.email())
                .orElseThrow(() -> new InvalidCredentialsException("Invalid email or password"));
        if (user.getPasswordHash() == null || !passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new InvalidCredentialsException("Invalid email or password");
        }
        return issueTokens(user);
    }

    public AuthResponse refresh(String rawRefreshToken) {
        RefreshTokenService.RotationResult rotation = refreshTokenService.rotate(rawRefreshToken);
        User user = userRepository
                .findById(rotation.userId())
                .orElseThrow(() -> new InvalidCredentialsException("User no longer exists"));
        return new AuthResponse(jwtService.generateAccessToken(user.getId()), rotation.rawToken(), toResponse(user));
    }

    public void logout(String rawRefreshToken) {
        refreshTokenService.revoke(rawRefreshToken);
    }

    private AuthResponse issueTokens(User user) {
        String accessToken = jwtService.generateAccessToken(user.getId());
        String refreshToken = refreshTokenService.issue(user.getId());
        return new AuthResponse(accessToken, refreshToken, toResponse(user));
    }

    public UserResponse toResponse(User user) {
        StreakResponse streak = streakService.computeUserStreak(user.getId());
        return new UserResponse(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getProfilePictureUrl(),
                user.getTimezone(),
                user.getCountry(),
                user.getLanguage(),
                user.isDarkModePreference(),
                user.getBio(),
                user.getLevel(),
                user.getXp(),
                streak.currentStreak(),
                streak.bestStreak(),
                user.getMemberSince());
    }
}

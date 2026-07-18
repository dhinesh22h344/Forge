package com.forge.user.entity;

import com.forge.common.audit.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.time.Instant;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

@Entity
@Table(name = "users")
@SQLDelete(sql = "UPDATE users SET deleted_at = now() WHERE id = ?")
@SQLRestriction("deleted_at IS NULL")
public class User extends BaseEntity {

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false, unique = true)
    private String email;

    /** BCrypt hash. Null once Firebase-only auth lands for an account (see docs/api/openapi.yaml /auth/session). */
    @Column(name = "password_hash")
    private String passwordHash;

    @Column(name = "profile_picture_url")
    private String profilePictureUrl;

    @Column(nullable = false)
    private String timezone;

    @Column(nullable = false)
    private String country;

    @Column(nullable = false)
    private String language;

    @Column(name = "dark_mode_preference", nullable = false)
    private boolean darkModePreference = true;

    @Column(length = 140)
    private String bio;

    @Column(nullable = false)
    private int level = 1;

    @Column(nullable = false)
    private long xp = 0;

    @Column(name = "member_since", nullable = false)
    private Instant memberSince = Instant.now();

    protected User() {}

    public User(String username, String email, String passwordHash, String timezone, String country, String language, boolean darkModePreference) {
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
        this.timezone = timezone;
        this.country = country;
        this.language = language;
        this.darkModePreference = darkModePreference;
    }

    public String getUsername() {
        return username;
    }

    public String getEmail() {
        return email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public String getProfilePictureUrl() {
        return profilePictureUrl;
    }

    public void setProfilePictureUrl(String profilePictureUrl) {
        this.profilePictureUrl = profilePictureUrl;
    }

    public String getTimezone() {
        return timezone;
    }

    public void setTimezone(String timezone) {
        this.timezone = timezone;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public boolean isDarkModePreference() {
        return darkModePreference;
    }

    public void setDarkModePreference(boolean darkModePreference) {
        this.darkModePreference = darkModePreference;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public int getLevel() {
        return level;
    }

    public long getXp() {
        return xp;
    }

    /**
     * 100 XP per level, flat — simplest curve that still makes early levels feel frequent.
     * Revisit with a real progression curve once Milestone 8 (Achievements) needs one.
     */
    public void addXp(long amount) {
        this.xp += amount;
        this.level = 1 + (int) (this.xp / 100);
    }

    public Instant getMemberSince() {
        return memberSince;
    }
}

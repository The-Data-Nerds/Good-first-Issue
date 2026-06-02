#!/usr/bin/env python3
"""
Contributor Badge Tier System - GitHub Actions Workflow Script

Updates contributor badges in README.md based on merged PR counts.
Runs automatically on PR merge events via GitHub Actions.

Tier System:
    🥉 First Timer - 1 PR merged
    🥈 Regular - 2-4 PRs merged  
    🥇 Champion - 5+ PRs merged

Author: DevOps Team
Version: 2.0.0
License: MIT
"""

import os
import sys
import json
import logging
import re
import time
from typing import Dict, List, Optional, Tuple, Set, Iterator, Any
from dataclasses import dataclass, field, asdict
from enum import Enum
from pathlib import Path
from datetime import datetime, timezone
from functools import lru_cache

import requests
from requests.adapters import HTTPAdapter
from requests.exceptions import (
    RequestException,
    HTTPError,
    ConnectionError,
    Timeout,
    RetryError
)
from urllib3.util.retry import Retry

# ---------------------------------------------------------------------------
# Configuration and Constants
# ---------------------------------------------------------------------------

class BadgeTier(Enum):
    """Enumeration of contributor badge tiers with their criteria."""
    
    FIRST_TIMER = ("🥉", "First Timer", 1, 1)
    REGULAR = ("🥈", "Regular", 2, 4)
    CHAMPION = ("🥇", "Champion", 5, float('inf'))
    
    def __init__(self, emoji: str, name: str, min_prs: int, max_prs: float):
        """Initialize badge tier with emoji, name, and PR count range."""
        self.emoji = emoji
        self.tier_name = name
        self.min_prs = min_prs
        self.max_prs = max_prs
    
    @classmethod
    def get_tier(cls, pr_count: int) -> "BadgeTier":
        """
        Determine badge tier based on PR count.
        
        Args:
            pr_count: Number of merged PRs
            
        Returns:
            Appropriate BadgeTier enum value
            
        Raises:
            ValueError: If pr_count is negative
        """
        if pr_count < 0:
            raise ValueError(f"PR count cannot be negative: {pr_count}")
        
        for tier in cls:
            if tier.min_prs <= pr_count <= tier.max_prs:
                return tier
        return cls.FIRST_TIMER


@dataclass
class Contributor:
    """Represents a project contributor with their PR statistics."""
    
    username: str
    pr_count: int = 0
    badge_tier: BadgeTier = BadgeTier.FIRST_TIMER
    profile_url: str = ""
    last_updated: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    
    def __post_init__(self) -> None:
        """Initialize derived fields after dataclass initialization."""
        self.profile_url = f"https://github.com/{self.username}"
        self.badge_tier = BadgeTier.get_tier(self.pr_count)
    
    def update_pr_count(self, new_count: int) -> None:
        """
        Update PR count and recalculate badge tier.
        
        Args:
            new_count: New PR count value
            
        Raises:
            ValueError: If new_count is negative
        """
        if new_count < 0:
            raise ValueError(f"PR count cannot be negative: {new_count}")
        
        self.pr_count = new_count
        self.badge_tier = BadgeTier.get_tier(new_count)
        self.last_updated = datetime.now(timezone.utc)
    
    def to_markdown_line(self) -> str:
        """
        Generate markdown list item for this contributor.
        
        Returns:
            Formatted markdown string with contributor link and badge
        """
        return f"- [{self.username}]({self.profile_url}) {self.badge_tier.emoji}"
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert contributor to dictionary for serialization."""
        return {
            "username": self.username,
            "pr_count": self.pr_count,
            "badge_tier": self.badge_tier.name,
            "profile_url": self.profile_url,
            "last_updated": self.last_updated.isoformat()
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "Contributor":
        """Create contributor from dictionary."""
        return cls(
            username=data["username"],
            pr_count=data.get("pr_count", 0),
            badge_tier=BadgeTier[data.get("badge_tier", "FIRST_TIMER")],
            profile_url=data.get("profile_url", ""),
            last_updated=datetime.fromisoformat(data.get("last_updated", datetime.now(timezone.utc).isoformat()))
        )


@dataclass
class RepositoryConfig:
    """Configuration for the target repository."""
    
    owner: str
    name: str
    readme_path: Path = field(default=Path("README.md"))
    cache_path: Path = field(default=Path(".contributor_cache.json"))
    
    def __post_init__(self) -> None:
        """Validate configuration after initialization."""
        if not self.owner or not self.owner.strip():
            raise ValueError("Repository owner cannot be empty")
        if not self.name or not self.name.strip():
            raise ValueError("Repository name cannot be empty")
        
        self.owner = self.owner.strip()
        self.name = self.name.strip()
    
    @property
    def api_base_url(self) -> str:
        """GitHub API base URL for this repository."""
        return f"https://api.github.com/repos/{self.owner}/{self.name}"
    
    @classmethod
    def from_environment(cls) -> "RepositoryConfig":
        """
        Create config from GitHub Actions environment variables.
        
        Returns:
            RepositoryConfig instance
            
        Raises:
            ValueError: If repository information cannot be determined
        """
        owner = os.environ.get("GITHUB_REPOSITORY_OWNER", "")
        repo_full = os.environ.get("GITHUB_REPOSITORY", "")
        
        if not owner and "/" in repo_full:
            owner, name = repo_full.split("/", 1)
        elif owner and "/" in repo_full:
            _, name = repo_full.split("/", 1)
        else:
            raise ValueError(
                "Cannot determine repository owner and name from environment. "
                "Ensure GITHUB_REPOSITORY or GITHUB_REPOSITORY_OWNER is set."
            )
        
        return cls(owner=owner, name=name)


# ---------------------------------------------------------------------------
# Logging Configuration
# ---------------------------------------------------------------------------

def setup_logging() -> logging.Logger:
    """
    Configure structured logging for the application.
    
    Returns:
        Configured logger instance
    """
    logger = logging.getLogger("contributor_badges")
    logger.setLevel(logging.DEBUG)
    
    # Prevent duplicate handlers
    if logger.handlers:
        return logger
    
    # Console handler with formatting
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    
    console_formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    console_handler.setFormatter(console_formatter)
    
    # File handler for detailed debugging
    try:
        file_handler = logging.FileHandler("contributor_badges.log")
        file_handler.setLevel(logging.DEBUG)
        file_formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(filename)s:%(lineno)d - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        file_handler.setFormatter(file_formatter)
        logger.addHandler(file_handler)
    except (IOError, PermissionError) as e:
        logger.warning(f"Could not create log file: {e}")
    
    logger.addHandler(console_handler)
    
    return logger


logger = setup_logging()


# ---------------------------------------------------------------------------
# GitHub API Client
# ---------------------------------------------------------------------------

class GitHubAPIClient:
    """Robust GitHub API client with retry logic, rate limiting, and error handling."""
    
    BASE_URL = "https://api.github.com"
    MAX_RETRIES = 3
    TIMEOUT = 30
    RATE_LIMIT_THRESHOLD = 10
    
    def __init__(self, token: str):
        """
        Initialize API client.
        
        Args:
            token: GitHub personal access token or GITHUB_TOKEN
            
        Raises:
            ValueError: If token is empty or invalid
        """
        if not token or not token.strip():
            raise ValueError("GitHub token is required and cannot be empty")
        
        self.token = token.strip()
        self.session = self._create_session()
        self._rate_limit_remaining: int = 5000
        self._rate_limit_reset: int = 0
    
    def _create_session(self) -> requests.Session:
        """Create configured requests session with retry logic."""
        session = requests.Session()
        
        # Configure retries with exponential backoff
        retry_strategy = Retry(
            total=self.MAX_RETRIES,
            backoff_factor=2,
            status_forcelist=[429, 500, 502, 503, 504],
            allowed_methods=["HEAD", "GET", "OPTIONS"],
            raise_on_status=False
        )
        
        adapter = HTTPAdapter(
            max_retries=retry_strategy,
            pool_connections=10,
            pool_maxsize=20
        )
        session.mount("https://", adapter)
        session.mount("http://", adapter)
        
        # Set headers
        session.headers.update({
            "Authorization": f"token {self.token}",
            "Accept": "application/vnd.github.v3+json",
            "User-Agent": "contributor-badge-system/2.0"
        })
        
        return session
    
    def _check_rate_limit(self, response: requests.Response) -> None:
        """
        Check and handle GitHub API rate limiting.
        
        Args:
            response: API response to extract rate limit headers from
        """
        self._rate_limit_remaining = int(response.headers.get("X-RateLimit-Remaining", 5000))
        self._rate_limit_reset = int(response.headers.get("X-RateLimit-Reset", 0))
        
        if self._rate_limit_remaining < self.RATE_LIMIT_THRESHOLD:
            reset_time = datetime.fromtimestamp(self._rate_limit_reset, tz=timezone.utc)
            wait_seconds = max(0, (reset_time - datetime.now(timezone.utc)).total_seconds())
            logger.warning(
                f"Rate limit low: {self._rate_limit_remaining} remaining. "
                f"Resets at {reset_time.isoformat()} ({wait_seconds:.0f} seconds)"
            )
            
            if wait_seconds > 0 and wait_seconds < 300:  # Wait up to 5 minutes
                logger.info(f"Waiting {wait_seconds:.0f} seconds for rate limit reset...")
                time.sleep(wait_seconds + 1)
    
    def _make_request(self, url: str, params: Optional[Dict[str, Any]] = None) -> requests.Response:
        """
        Make HTTP request with error handling and rate limiting.
        
        Args:
            url: Request URL
            params: Query parameters
            
        Returns:
            Response object
            
        Raises:
            HTTPError: On HTTP errors after retries
            ConnectionError: On connection failures
            Timeout: On request timeout
        """
        try:
            response = self.session.get(
                url,
                params=params,
                timeout=self.TIMEOUT
            )
            
            self._check_rate_limit(response)
            response.raise_for_status()
            
            return response
            
        except HTTPError as e:
            logger.error(f"HTTP error {e.response.status_code} for {url}: {e}")
            if e.response.status_code == 403:
                logger.error("Access forbidden. Check token permissions.")
            elif e.response.status_code == 404:
                logger.error(f"Resource not found: {url}")
            raise
            
        except ConnectionError as e:
            logger.error(f"Connection error for {url}: {e}")
            raise
            
        except Timeout as e:
            logger.error(f"Request timeout for {url}: {e}")
            raise
            
        except RequestException as e:
            logger.error(f"Request failed for {url}: {e}")
            raise
    
    def get_merged_prs(self, repo_config: RepositoryConfig) -> List[Dict[str, Any]]:
        """
        Fetch all merged pull requests for the repository.
        
        Args:
            repo_config: Repository configuration
            
        Returns:
            List of merged PR data dictionaries
            
        Raises:
            RequestException: On API request failure
            ValueError: On invalid response data
        """
        url = f"{repo_config.api_base_url}/pulls"
        params: Dict[str, Any] = {
            "state": "closed",
            "sort": "updated",
            "direction": "desc",
            "per_page": 100
        }
        
        all_prs: List[Dict[str, Any]] = []
        page = 1
        
        try:
            while True:
                params["page"] = page
                logger.debug(f"Fetching PRs page {page} from {url}")
                
                response = self._make_request(url, params=params)
                
                try:
                    prs = response.json()
                except json.JSONDecodeError as e:
                    logger.error(f"Invalid JSON response: {e}")
                    raise ValueError(f"Invalid JSON response from GitHub API: {e}")
                
                if not isinstance(prs, list):
                    logger.error(f"Unexpected response format: {type(prs)}")
                    raise ValueError("Expected list response from GitHub API")
                
                if not prs:
                    break
                
                # Filter for merged PRs only
                merged_prs = [
                    pr for pr in prs 
                    if isinstance(pr, dict) and pr.get("merged_at") is not None
                ]
                all_prs.extend(merged_prs)
                
                logger.debug(f"Found {len(merged_prs)} merged PRs on page {page}")
                
                # Check for pagination
                if len(prs) < 100:
                    break
                    
                page += 1
                
                # Respect rate limiting between pages
                if self._rate_limit_remaining < 100:
                    logger.info("Rate limit getting low, adding delay between pages...")
                    time.sleep(1)
                    
        except (RequestException, ValueError) as e:
            logger.error(f"Failed to fetch merged PRs: {e}")
            raise
        
        logger.info(f"Total merged PRs found: {len(all_prs)}")
        return all_prs
    
    def get_contributor_pr_counts(self, repo_config: RepositoryConfig) -> Dict[str, int]:
        """
        Get PR count per contributor from merged PRs.
        
        Args:
            repo_config: Repository configuration
            
        Returns:
            Dictionary mapping username to PR count
        """
        merged_prs = self.get_merged_prs(repo_config)
        
        contributor_counts: Dict[str, int] = {}
        
        for pr in merged_prs:
            try:
                user = pr.get("user", {})
                if not isinstance(user, dict):
                    logger.warning(f"Invalid user data in PR: {pr.get('id', 'unknown')}")
                    continue
                    
                username = user.get("login")
                if not username or not isinstance(username, str):
                    logger.warning(f"Missing or invalid username in PR: {pr.get('id', 'unknown')}")
                    continue
                
                contributor_counts[username] = contributor_counts.get(username, 0) + 1
                
            except (KeyError, TypeError, AttributeError) as e:
                logger.warning(f"Error processing PR data: {e}")
                continue
        
        logger.info(f"Found {len(contributor_counts)} unique contributors")
        return contributor_counts


# ---------------------------------------------------------------------------
# README Parser and Updater
# ---------------------------------------------------------------------------

class READMEUpdater:
    """Handles parsing and updating contributor badges in README.md."""
    
    CONTRIBUTORS_SECTION_START = "<!-- CONTRIBUTORS:START -->"
    CONTRIBUTORS_SECTION_END = "<!-- CONTRIBUTORS:END -->"
    
    def __init__(self, readme_path: Path):
        """
        Initialize README updater.
        
        Args:
            readme_path: Path to README.md file
            
        Raises:
            FileNotFoundError: If README doesn't exist
            PermissionError: If README can't be read
        """
        self.readme_path = readme_path
        
        if not self.readme_path.exists():
            raise FileNotFoundError(f"README file not found: {self.readme_path}")
        
        if not self.readme_path.is_file():
            raise ValueError(f"Path is not a file: {self.readme_path}")
    
    def read_content(self) -> str:
        """
        Read README content.
        
        Returns:
            README content as string
            
        Raises:
            IOError: On read failure
        """
        try:
            content = self.readme_path.read_text(encoding="utf-8")
            logger.debug(f"Read {len(content)} characters from {self.readme_path}")
            return content
        except (IOError, PermissionError) as e:
            logger.error(f"Failed to read README: {e}")
            raise
    
    def write_content(self, content: str) -> None:
        """
        Write content to README.
        
        Args:
            content: New README content
            
        Raises:
            IOError: On write failure
        """
        try:
            self.readme_path.write_text(content, encoding="utf-8")
            logger.info(f"Successfully wrote {len(content)} characters to {self.readme_path}")
        except (IOError, PermissionError) as e:
            logger.error(f"Failed to write README: {e}")
            raise
    
    def has_contributors_section(self, content: str) -> bool:
        """
        Check if README has contributors section markers.
        
        Args:
            content: README content
            
        Returns:
            True if section markers exist
        """
        return (
            self.CONTRIBUTORS_SECTION_START in content and 
            self.CONTRIBUTORS_SECTION_END in content
        )
    
    def create_contributors_section(self, content: str) -> str:
        """
        Add contributors section markers to README if missing.
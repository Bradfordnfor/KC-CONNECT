Write-Host "🚀 Creating KC CONNECT Flutter folder structure..." -ForegroundColor Cyan

$folders = @(
    "lib/core/config",
    "lib/core/theme",
    "lib/core/utils",
    "lib/core/widgets",
    "lib/core/services",

    "lib/features/home/presentation/screens",
    "lib/features/home/presentation/widgets",
    "lib/features/home/data",
    "lib/features/home/domain",

    "lib/features/chat/presentation/screens",
    "lib/features/chat/presentation/widgets",
    "lib/features/chat/data",
    "lib/features/chat/domain",

    "lib/features/resources/presentation/screens",
    "lib/features/resources/presentation/widgets",
    "lib/features/resources/data",
    "lib/features/resources/domain",

    "lib/features/events/presentation/screens",
    "lib/features/events/presentation/widgets",
    "lib/features/events/data",
    "lib/features/events/domain",

    "lib/features/kstore/presentation/screens",
    "lib/features/kstore/presentation/widgets",
    "lib/features/kstore/data",
    "lib/features/kstore/domain",

    "lib/features/profile/presentation/screens",
    "lib/features/profile/presentation/widgets",
    "lib/features/profile/data",
    "lib/features/profile/domain",

    "lib/features/alumni/presentation/screens",
    "lib/features/alumni/presentation/widgets",
    "lib/features/alumni/data",
    "lib/features/alumni/domain",

    "lib/features/notifications/presentation/screens",
    "lib/features/notifications/presentation/widgets",
    "lib/features/notifications/data",
    "lib/features/notifications/domain",

    "lib/features/shared/widgets",
    "lib/features/shared/models",

    "lib/localization"
)

foreach ($folder in $folders) {
    if (-Not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
        Write-Host "Created: $folder"
    } else {
        Write-Host "Exists: $folder"
    }
}

$files = @(
    "lib/core/theme/app_colors.dart",
    "lib/core/theme/app_text_styles.dart",
    "lib/core/theme/app_theme.dart",
    "lib/core/config/app_constants.dart",
    "lib/core/config/router.dart",
    "lib/main.dart",
    "lib/injection_container.dart"
)

foreach ($file in $files) {
    if (-Not (Test-Path $file)) {
        New-Item -ItemType File -Path $file | Out-Null
        Write-Host "Created file: $file"
    } else {
        Write-Host "Exists: $file"
    }
}

Write-Host "`n✅ KC CONNECT folder structure created successfully!" -ForegroundColor Green

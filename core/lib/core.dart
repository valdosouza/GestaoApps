// Core Library - Módulo compartilhado para Apps ERP
// Exportações centralizadas de todos os módulos

library core;

// ===== SPLASH MODULE =====
// Domain
export 'src/splash/domain/repository/splash_respository.dart';
export 'src/splash/domain/usecase/get_authorization.dart';

// Data
export 'src/splash/data/datasource/splash_datasource.dart';
export 'src/splash/data/repository/splash_repository_impl.dart';

// Presentation
export 'src/splash/presentation/bloc/splash_bloc.dart';
export 'src/splash/presentation/bloc/splash_event.dart';
export 'src/splash/presentation/bloc/splash_state.dart';
export 'src/splash/presentation/page/splash_page.dart';

// Module
export 'src/splash/splash_module.dart';

// ===== AUTH MODULE =====
// Domain - Entities
export 'src/auth/domain/entity/auth_entity.dart';
export 'src/auth/domain/entity/auth_change_password_entity.dart';
export 'src/auth/domain/entity/auth_recovery_password_entity.dart';

// Domain - Repository & UseCases
export 'src/auth/domain/repository/auth_repository.dart';
export 'src/auth/domain/usecase/login_email.dart';
export 'src/auth/domain/usecase/change_password.dart';
export 'src/auth/domain/usecase/recovery_password.dart';

// Data - Models
export 'src/auth/data/model/auth_model.dart';
export 'src/auth/data/model/auth_change_password_model.dart';
export 'src/auth/data/model/auth_recovery_password_model.dart';

// Data - DataSources
export 'src/auth/data/datasource/local/auth_local_datasource.dart';
export 'src/auth/data/datasource/remote/auth_datasource.dart';

// Data - Repository Implementation
export 'src/auth/data/repository/auth_repository_impl.dart';

// Presentation - BLoC
export 'src/auth/presentation/bloc/auth_bloc.dart';
export 'src/auth/presentation/bloc/auth_event.dart';
export 'src/auth/presentation/bloc/auth_state.dart';

// Presentation - Pages
export 'src/auth/presentation/page/auth_page.dart';
export 'src/auth/presentation/page/auth_form.dart';
export 'src/auth/presentation/page/server_ip_page.dart';

// Module
export 'src/auth/auth_module.dart';

// ===== THEME MODULE =====
export 'src/core/theme/app_theme.dart';
export 'src/core/theme/app_colors.dart';

// ===== CORE MODULE =====
// Dependency Injection
export 'src/core/di/injection_container.dart';

// Error Handling
export 'src/core/error/failure.dart';

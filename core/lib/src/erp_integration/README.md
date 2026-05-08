# 🌐 ERP Integration Module

Módulo para integração com APIs do sistema ERP.

## 📋 Estrutura

```
erp_integration/
├── domain/
│   ├── entities/
│   │   ├── product.dart
│   │   ├── customer.dart
│   │   └── order.dart
│   ├── repositories/
│   │   ├── product_repository.dart
│   │   └── customer_repository.dart
│   └── usecases/
│       ├── get_products.dart
│       └── get_customers.dart
├── data/
│   ├── datasources/
│   │   ├── erp_api_datasource.dart
│   │   └── erp_cache_datasource.dart
│   ├── models/
│   │   ├── product_model.dart
│   │   └── customer_model.dart
│   └── repositories/
│       └── *_repository_impl.dart
└── presentation/
    └── (cubits/widgets conforme necessário)
```

## 🚀 Próximos Passos

- [ ] Implementar API Client (Dio/HTTP)
- [ ] Criar Entities (Product, Customer, Order)
- [ ] Implementar Data Sources
- [ ] Criar Repositories
- [ ] Adicionar Caching
- [ ] Testes unitários

---

**Status**: Em desenvolvimento

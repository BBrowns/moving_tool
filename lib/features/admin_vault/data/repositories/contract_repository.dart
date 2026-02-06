import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moving_tool_flutter/features/admin_vault/domain/entities/service_contract.dart';

/// Repository interface for ServiceContract persistence.
abstract class ContractRepository {
  Future<List<ServiceContract>> getContracts(String projectId);
  Future<void> saveContract(ServiceContract contract);
  Future<void> deleteContract(String contractId);
}

/// SharedPreferences implementation of ContractRepository.
class ContractRepositoryImpl implements ContractRepository {
  ContractRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'contracts';

  @override
  Future<List<ServiceContract>> getContracts(String projectId) async {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return [];

    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => ServiceContract.fromJson(e as Map<String, dynamic>))
        .where((c) => c.projectId == projectId)
        .toList();
  }

  @override
  Future<void> saveContract(ServiceContract contract) async {
    final contracts = await _getAllContracts();
    final index = contracts.indexWhere((c) => c.id == contract.id);

    if (index >= 0) {
      contracts[index] = contract;
    } else {
      contracts.add(contract);
    }

    await _saveAll(contracts);
  }

  @override
  Future<void> deleteContract(String contractId) async {
    final contracts = await _getAllContracts();
    contracts.removeWhere((c) => c.id == contractId);
    await _saveAll(contracts);
  }

  Future<List<ServiceContract>> _getAllContracts() async {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return [];

    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => ServiceContract.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<ServiceContract> contracts) async {
    final jsonStr = jsonEncode(contracts.map((c) => c.toJson()).toList());
    await _prefs.setString(_key, jsonStr);
  }
}

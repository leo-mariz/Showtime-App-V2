import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:app/features/contracts/presentation/bloc/events/contracts_events.dart';
import 'package:app/features/contracts/presentation/bloc/states/contracts_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Widget que exibe informações formatadas do contrato
/// 
/// Formato: "Tipo de evento - Data - Horário"
/// Exemplo: "Aniversário - 15/01/2026 - 18:00"
class ContractInfoWidget extends StatefulWidget {
  final String contractId;
  final TextStyle? textStyle;
  final TextAlign? textAlign;

  const ContractInfoWidget({
    super.key,
    required this.contractId,
    this.textStyle,
    this.textAlign,
  });

  @override
  State<ContractInfoWidget> createState() => _ContractInfoWidgetState();
}

class _ContractInfoWidgetState extends State<ContractInfoWidget> {
  ContractEntity? _cachedContract;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Buscar contrato ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _cachedContract == null && !_isLoading) {
        _loadContract();
      }
    });
  }

  void _loadContract() {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    context.read<ContractsBloc>().add(GetContractEvent(contractUid: widget.contractId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContractsBloc, ContractsState>(
      listener: (context, state) {
        if (state is GetContractSuccess && state.contract.uid == widget.contractId) {
          if (mounted) {
            setState(() {
              _cachedContract = state.contract;
              _isLoading = false;
            });
          }
        } else if (state is GetContractFailure) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
      child: BlocBuilder<ContractsBloc, ContractsState>(
        buildWhen: (previous, current) {
          // Reconstruir quando o contrato específico for carregado
          if (current is GetContractSuccess && current.contract.uid == widget.contractId) {
            return true;
          }
          return false;
        },
        builder: (context, state) {
          // Se temos o contrato em cache, usar ele
          if (_cachedContract != null && _cachedContract!.uid == widget.contractId) {
            return _buildContractInfo(context, _cachedContract!);
          }
          
          // Se o estado atual tem o contrato que buscamos, usar e cachear
          if (state is GetContractSuccess && state.contract.uid == widget.contractId) {
            _cachedContract = state.contract;
            return _buildContractInfo(context, state.contract);
          }
          
          // Fallback: mostrar apenas o ID do contrato enquanto carrega
          return _buildFallback(context);
        },
      ),
    );
  }

  Widget _buildContractInfo(BuildContext context, ContractEntity contract) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Formatar informações
    final eventTypeName = contract.eventType?.name ?? 'Evento';
    final dateFormatted = DateFormat('dd/MM/yyyy', 'pt_BR').format(contract.date);
    final timeFormatted = contract.time; // Já vem no formato "HH:mm"
    
    final infoText = '$eventTypeName - $dateFormatted - $timeFormatted';
    
    return Text(
      infoText,
      style: widget.textStyle ?? textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        fontSize: calculateFontSize(12),
      ),
      textAlign: widget.textAlign ?? TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFallback(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Text(
      'Contrato #${widget.contractId}',
      style: widget.textStyle ?? textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        fontSize: calculateFontSize(12),
      ),
      textAlign: widget.textAlign ?? TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

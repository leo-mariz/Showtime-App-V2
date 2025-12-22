import 'package:flutter/material.dart';
import 'package:app/core/design_system/size/ds_size.dart';

/// Widget de indicador de progresso para fluxos multi-step
/// 
/// Exibe barras horizontais indicando em qual step o usuário está
class ProgressIndicatorWidget extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const ProgressIndicatorWidget({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: List.generate(totalSteps, (index) {
        // Step 0 = primeira barra (index 0), Step 1 = segunda barra (index 1)
        // Quando currentStep = 0, primeira barra (index 0) deve estar preenchida
        // Quando currentStep = 1, ambas as barras (index 0 e 1) devem estar preenchidas
        // Usamos index <= currentStep para preencher todas as barras até o step atual
        final isActive = index <= currentStep;
        
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: DSSize.width(4)),
            height: DSSize.height(4),
            decoration: BoxDecoration(
              color: isActive 
                ? colorScheme.onPrimary 
                : colorScheme.primaryContainer.withValues(alpha: 0.3 * 255),
              borderRadius: BorderRadius.circular(DSSize.width(2)),
            ),
          ),
        );
      }),
    );
  }
}


// Export all models
export 'package:moving_tool_flutter/features/expenses/domain/entities/expense.dart';
export 'package:moving_tool_flutter/features/packing/domain/entities/box_item.dart';
export 'package:moving_tool_flutter/features/packing/domain/entities/packing_box.dart';
export 'package:moving_tool_flutter/features/packing/domain/entities/room.dart';
export 'package:moving_tool_flutter/features/playbook/domain/entities/journal_entry.dart';
export 'package:moving_tool_flutter/features/playbook/domain/entities/playbook_note.dart';
export 'package:moving_tool_flutter/features/projects/domain/entities/project.dart';
export 'package:moving_tool_flutter/features/shopping/domain/entities/shopping_item.dart';
export 'package:moving_tool_flutter/features/tasks/domain/entities/task.dart';

// New Advanced Feature Entities
export 'package:moving_tool_flutter/core/models/item_dimensions.dart';
export 'package:moving_tool_flutter/features/assets/domain/entities/asset.dart';
export 'package:moving_tool_flutter/features/assets/domain/entities/ownership_share.dart';
// AR Room is exported as ARRoom to avoid collision with Packing Room
export 'package:moving_tool_flutter/features/ar_studio/domain/entities/room.dart'
    show VirtualItem, ARPlacement, RoomDimensions;
export 'package:moving_tool_flutter/features/admin_vault/domain/entities/service_contract.dart';
export 'package:moving_tool_flutter/features/admin_vault/domain/entities/metric_log.dart';

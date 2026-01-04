import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Function(int)? onFeedback;
  
  const MessageBubble({
    super.key,
    required this.message,
    this.onFeedback,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: message.isUser 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isError 
                  ? Colors.red.shade50
                  : message.isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message.text,
                    style: TextStyle(
                      color: message.isError
                        ? Colors.red.shade900
                        : message.isUser
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                  
                  // Metadata for bot messages
                  if (!message.isUser && !message.isError) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (message.confidence != null)
                          _buildChip(
                            context,
                            Icons.psychology,
                            '${(message.confidence! * 100).toStringAsFixed(0)}%',
                          ),
                        if (message.responseTime != null)
                          _buildChip(
                            context,
                            Icons.speed,
                            '${message.responseTime!.toStringAsFixed(2)}s',
                          ),
                      ],
                    ),
                  ],
                  
                  // Sources
                  if (message.sources != null && message.sources!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.source, size: 14, 
                                color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                'Sources:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ...message.sources!.take(3).map((source) => Padding(
                            padding: const EdgeInsets.only(left: 18, top: 2),
                            child: Text(
                              '• $source',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Timestamp and actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeago.format(message.timestamp, locale: 'en_short'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                
                // Feedback buttons for bot messages
                if (!message.isUser && !message.isError && onFeedback != null) ...[
                  const SizedBox(width: 8),
                  _buildFeedbackButton(
                    context,
                    Icons.thumb_up_outlined,
                    1,
                    message.rating == 1,
                  ),
                  const SizedBox(width: 4),
                  _buildFeedbackButton(
                    context,
                    Icons.thumb_down_outlined,
                    -1,
                    message.rating == -1,
                  ),
                ],
                
                // Copy button
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: message.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeedbackButton(
    BuildContext context,
    IconData icon,
    int rating,
    bool isSelected,
  ) {
    return IconButton(
      icon: Icon(icon, size: 16),
      iconSize: 16,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
      onPressed: () => onFeedback?.call(rating),
    );
  }
}
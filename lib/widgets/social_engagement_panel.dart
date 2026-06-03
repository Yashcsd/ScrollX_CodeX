import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_theme.dart';
import '../models/game_comment_model.dart';
import '../models/game_social_metadata.dart';
import '../models/game_social_model.dart';
import '../models/user_model.dart';
import '../services/game_social_service.dart';
import '../services/user_provider.dart';
import '../widgets/bounce_press.dart';
import 'common_widgets.dart';

class SocialEngagementPanel extends StatefulWidget {
  final String gameId;
  final GameSocialMetadata metadata;
  final Color color;

  const SocialEngagementPanel({
    super.key,
    required this.gameId,
    required this.metadata,
    this.color = Colors.white,
  });

  @override
  State<SocialEngagementPanel> createState() => _SocialEngagementPanelState();
}

class _SocialEngagementPanelState extends State<SocialEngagementPanel> {
  bool _likeBusy = false;
  bool? _optimisticLiked;
  int _likeDelta = 0;

  Future<void> _toggleLike() async {
    if (_likeBusy) return;

    final provider = context.read<UserProvider>();
    final socialUser = await provider.ensureAuthenticatedUser();
    if (!mounted) return;
    if (socialUser == null) {
      _showError('Could not sign in for likes.');
      return;
    }

    final currentlyLiked = _optimisticLiked ?? false;
    setState(() {
      _likeBusy = true;
      _optimisticLiked = !currentlyLiked;
      _likeDelta += currentlyLiked ? -1 : 1;
    });

    try {
      await GameSocialService.toggleLike(
        gameId: widget.gameId,
        userId: socialUser.id,
        metadata: widget.metadata,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _optimisticLiked = currentlyLiked;
          _likeDelta += currentlyLiked ? 1 : -1;
        });
        final errMsg = e.toString().replaceAll('Exception: ', '');
        _showError(errMsg);
      }
    } finally {
      if (mounted) {
        setState(() => _likeBusy = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.dark,
        ),
      );
  }

  String _fmtCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}m';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}k';
    return '$n';
  }

  Future<void> _openCommentsSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(
        gameId: widget.gameId,
        metadata: widget.metadata,
      ),
    );
  }

  Future<void> _shareGame(UserModel? user) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        title: 'ScrollX',
        subject: 'Play ${widget.metadata.name} on ScrollX',
        text:
            'Check out ${widget.metadata.name} on ScrollX.\n${widget.metadata.description}\n#ScrollX #MiniGames',
      ),
    );

    if (result.status == ShareResultStatus.success ||
        result.status == ShareResultStatus.unavailable) {
      await GameSocialService.share(
        gameId: widget.gameId,
        user: user,
        metadata: widget.metadata,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return StreamBuilder<GameSocialStats>(
      stream: GameSocialService.statsStream(widget.gameId),
      builder: (context, statsSnapshot) {
        final stats = statsSnapshot.data;

        return StreamBuilder<GameUserSocialState>(
          stream: GameSocialService.userStateStream(
            gameId: widget.gameId,
            userId: user?.id,
          ),
          builder: (context, userStateSnapshot) {
            final userState =
                userStateSnapshot.data ?? const GameUserSocialState();

            if (_optimisticLiked != null &&
                _optimisticLiked == userState.liked &&
                _likeDelta != 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  _optimisticLiked = null;
                  _likeDelta = 0;
                });
              });
            }

            final effectiveLiked = _optimisticLiked ?? userState.liked;
            final baseLikes = stats?.likes ?? 0;
            final effectiveLikes = baseLikes + _likeDelta;

            final likesText = _fmtCount(effectiveLikes < 0 ? 0 : effectiveLikes);
            final commentsText = _fmtCount(stats?.comments ?? 0);
            final sharesText = _fmtCount(stats?.shares ?? 0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SideAction(
                  icon: Icons.favorite_rounded,
                  label: likesText,
                  color: widget.color,
                  selected: effectiveLiked,
                  busy: _likeBusy,
                  onTap: _toggleLike,
                ),
                const SizedBox(height: 20),
                _SideAction(
                  icon: Icons.chat_bubble_rounded,
                  label: commentsText,
                  color: widget.color,
                  onTap: _openCommentsSheet,
                ),
                const SizedBox(height: 20),
                _SideAction(
                  icon: Icons.near_me_rounded,
                  label: sharesText,
                  color: widget.color,
                  onTap: () => _shareGame(user),
                ),
                const SizedBox(height: 20),
                _SideAction(
                  icon: Icons.more_horiz_rounded,
                  label: '',
                  color: widget.color,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SideAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final bool busy;
  final VoidCallback? onTap;

  const _SideAction({
    required this.icon,
    required this.label,
    required this.color,
    this.selected = false,
    this.busy = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => BouncePressWidget(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        icon,
                        color: selected ? AppTheme.coral : color,
                        size: 26,
                      ),
              ),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  shadows: const [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(0, 1.5),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
}

class _CommentsSheet extends StatefulWidget {
  final String gameId;
  final GameSocialMetadata metadata;

  const _CommentsSheet({
    required this.gameId,
    required this.metadata,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _submitting = false;
  String? _errorText;
  GameComment? _replyingTo;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_submitting) return;

    final provider = context.read<UserProvider>();
    final user = await provider.ensureAuthenticatedUser();
    final text = _controller.text.trim();
    if (user == null) {
      if (mounted) {
        setState(() => _errorText = 'Could not sign in for comments.');
      }
      return;
    }
    if (text.isEmpty) return;

    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await GameSocialService.addComment(
        gameId: widget.gameId,
        user: user,
        text: text,
        metadata: widget.metadata,
        parentCommentId: _replyingTo?.id,
      );
      _controller.clear();
      setState(() {
        _replyingTo = null;
      });
      _focusNode.unfocus();
    } catch (e) {
      if (mounted) {
        final errMsg = e.toString().replaceAll('Exception: ', '');
        setState(() => _errorText = errMsg);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _startReply(GameComment comment) {
    setState(() {
      _replyingTo = comment;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 24, 12, bottomInset + 12),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [AppTheme.hardShadowStrong],
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                child: Row(
                  children: [
                    Text(
                      '${widget.metadata.name} Comments',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<GameComment>>(
                  stream: GameSocialService.commentsStream(widget.gameId),
                  builder: (context, snapshot) {
                    final allComments = snapshot.data ?? const <GameComment>[];
                    if (allComments.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'No comments yet. Start the conversation.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textSec,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }

                    final rootComments = allComments
                        .where((c) => c.parentCommentId == null)
                        .toList();

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                      itemCount: rootComments.length,
                      itemBuilder: (context, index) {
                        final rootComment = rootComments[index];
                        final replies = allComments
                            .where((c) => c.parentCommentId == rootComment.id)
                            .toList()
                          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CommentTile(
                              comment: rootComment,
                              onReply: () => _startReply(rootComment),
                            ),
                            if (replies.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 36, top: 8),
                                child: Column(
                                  children: replies.map((reply) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: _CommentTile(
                                        comment: reply,
                                        isReply: true,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              if (_replyingTo != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  color: AppTheme.bgWarm,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Replying to @${_replyingTo!.username}',
                          style: const TextStyle(
                            color: AppTheme.textSec,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _cancelReply,
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.border),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AvatarWidget(
                      initials: user?.avatarInitials ?? 'PL',
                      size: 40,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submitComment(),
                        decoration: InputDecoration(
                          hintText: user == null
                              ? 'Create a profile to comment'
                              : 'Write a comment...',
                          hintStyle: const TextStyle(color: AppTheme.textMuted),
                          filled: true,
                          fillColor: AppTheme.bgWarm,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        enabled: user != null && !_submitting,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap:
                          user == null || _submitting ? null : _submitComment,
                      child: AnimatedOpacity(
                        opacity: _submitting ? 0.75 : 1,
                        duration: const Duration(milliseconds: 120),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: user == null
                                ? AppTheme.border
                                : AppTheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: const [AppTheme.hardShadowSmall],
                          ),
                          child: _submitting
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(
                                  Icons.near_me_rounded,
                                  color: Colors.black,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _errorText!,
                      style: const TextStyle(
                        color: AppTheme.coral,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final GameComment comment;
  final bool isReply;
  final VoidCallback? onReply;

  const _CommentTile({
    required this.comment,
    this.isReply = false,
    this.onReply,
  });

  String _timeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarWidget(initials: comment.avatarInitials, size: isReply ? 32 : 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgWarm,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              comment.username,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            _timeAgo(comment.createdAt),
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        comment.text,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isReply && onReply != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                    child: GestureDetector(
                      onTap: onReply,
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                          color: AppTheme.textSec,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
}

"""Add Community Challenge module tables

Revision ID: 001_add_community_challenges
Revises: 
Create Date: 2025-12-12

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '001_add_community_challenges'
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create community_challenges table
    op.create_table(
        'community_challenges',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('creator_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('title', sa.String(255), nullable=False),
        sa.Column('description', sa.Text(), nullable=False),
        sa.Column('category', sa.String(32), nullable=False),
        sa.Column('latitude', sa.Numeric(10, 7), nullable=False),
        sa.Column('longitude', sa.Numeric(10, 7), nullable=False),
        sa.Column('county', sa.String(100), nullable=True),
        sa.Column('district', sa.String(100), nullable=True),
        sa.Column('needed_resources', postgresql.JSONB, default={}),
        sa.Column('urgency_level', sa.String(20), default='medium'),
        sa.Column('duration_days', sa.Integer, nullable=True),
        sa.Column('expected_impact', sa.Text, nullable=True),
        sa.Column('status', sa.String(32), default='active'),
        sa.Column('progress_percentage', sa.Numeric(5, 2), default=0.0),
        sa.Column('media_urls', postgresql.JSONB, default=[]),
        sa.Column('created_at', sa.DateTime, default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime, default=sa.func.now(), onupdate=sa.func.now()),
        sa.Column('expires_at', sa.DateTime, nullable=True),
    )
    
    # Create challenge_participations table
    op.create_table(
        'challenge_participations',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('challenge_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('community_challenges.id', ondelete='CASCADE'), nullable=False),
        sa.Column('role', sa.String(32), nullable=False),
        sa.Column('contribution_details', postgresql.JSONB, default={}),
        sa.Column('created_at', sa.DateTime, default=sa.func.now()),
    )
    
    # Create challenge_progress table
    op.create_table(
        'challenge_progress',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('challenge_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('community_challenges.id', ondelete='CASCADE'), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('description', sa.Text(), nullable=False),
        sa.Column('media_urls', postgresql.JSONB, default=[]),
        sa.Column('progress_percentage', sa.Numeric(5, 2), nullable=False),
        sa.Column('milestone', sa.String(255), nullable=True),
        sa.Column('created_at', sa.DateTime, default=sa.func.now()),
    )
    
    # Create stakeholder_supports table
    op.create_table(
        'stakeholder_supports',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('stakeholder_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('challenge_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('community_challenges.id', ondelete='CASCADE'), nullable=False),
        sa.Column('support_type', sa.String(32), nullable=False),
        sa.Column('details', postgresql.JSONB, default={}),
        sa.Column('is_high_priority', sa.Boolean, default=False),
        sa.Column('created_at', sa.DateTime, default=sa.func.now()),
    )
    
    # Add challenge_id to notifications table
    op.add_column('notifications', sa.Column('challenge_id', postgresql.UUID(as_uuid=True), nullable=True))
    op.create_foreign_key(
        'fk_notifications_challenge_id',
        'notifications',
        'community_challenges',
        ['challenge_id'],
        ['id'],
        ondelete='CASCADE'
    )
    
    # Make report_id nullable in notifications (for challenge notifications)
    op.alter_column('notifications', 'report_id', nullable=True)
    
    # Create indexes
    op.create_index('idx_challenges_location', 'community_challenges', ['latitude', 'longitude'])
    op.create_index('idx_challenges_category', 'community_challenges', ['category'])
    op.create_index('idx_challenges_status', 'community_challenges', ['status'])
    op.create_index('idx_participations_challenge', 'challenge_participations', ['challenge_id'])
    op.create_index('idx_participations_user', 'challenge_participations', ['user_id'])
    op.create_index('idx_progress_challenge', 'challenge_progress', ['challenge_id'])
    op.create_index('idx_supports_challenge', 'stakeholder_supports', ['challenge_id'])


def downgrade() -> None:
    # Drop indexes
    op.drop_index('idx_supports_challenge')
    op.drop_index('idx_progress_challenge')
    op.drop_index('idx_participations_user')
    op.drop_index('idx_participations_challenge')
    op.drop_index('idx_challenges_status')
    op.drop_index('idx_challenges_category')
    op.drop_index('idx_challenges_location')
    
    # Revert notifications changes
    op.alter_column('notifications', 'report_id', nullable=False)
    op.drop_constraint('fk_notifications_challenge_id', 'notifications', type_='foreignkey')
    op.drop_column('notifications', 'challenge_id')
    
    # Drop tables
    op.drop_table('stakeholder_supports')
    op.drop_table('challenge_progress')
    op.drop_table('challenge_participations')
    op.drop_table('community_challenges')


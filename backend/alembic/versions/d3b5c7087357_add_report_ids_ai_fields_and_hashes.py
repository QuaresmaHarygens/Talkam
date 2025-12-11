"""add_report_ids_ai_fields_and_hashes

Revision ID: 20251207_000001
Revises: 20250205_000001
Create Date: 2025-12-07 17:21:06.000382
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision = "20251207_000001"
down_revision = "20250205_000001"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Add new fields to reports table
    op.add_column('reports', sa.Column('report_id', sa.String(20), unique=True, nullable=True))
    op.add_column('reports', sa.Column('priority_score', sa.Numeric(3, 2), nullable=True))
    op.add_column('reports', sa.Column('ai_category', sa.String(50), nullable=True))
    op.add_column('reports', sa.Column('recommended_agency', sa.String(100), nullable=True))
    op.add_column('reports', sa.Column('is_likely_fake', sa.Boolean(), nullable=False, server_default=sa.false()))
    op.add_column('reports', sa.Column('fake_confidence', sa.Numeric(3, 2), nullable=True))
    op.add_column('reports', sa.Column('legal_advice_snapshot', sa.Text(), nullable=True))
    op.add_column('reports', sa.Column('hash_anchored_on_chain', sa.Text(), nullable=True))
    
    # Add hash and metadata fields to report_media table
    op.add_column('report_media', sa.Column('hash_sha256', sa.String(64), nullable=True))
    op.add_column('report_media', sa.Column('metadata', postgresql.JSONB(), nullable=True))
    
    # Create report_hashes table for chain of custody
    op.create_table(
        'report_hashes',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('report_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('reports.id', ondelete='CASCADE'), nullable=False),
        sa.Column('evidence_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('report_media.id', ondelete='CASCADE'), nullable=True),
        sa.Column('hash_sha256', sa.String(64), nullable=False),
        sa.Column('anchored_on_chain', sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column('chain_tx_hash', sa.Text(), nullable=True),
        sa.Column('created_at', sa.TIMESTAMP(timezone=True), server_default=sa.func.now()),
    )
    op.create_index('ix_report_hashes_report_id', 'report_hashes', ['report_id'])
    op.create_index('ix_report_hashes_hash_sha256', 'report_hashes', ['hash_sha256'])
    
    # Create audit_logs table (immutable audit trail)
    op.create_table(
        'audit_logs',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('actor_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=True),
        sa.Column('actor_type', sa.String(20), nullable=False),  # 'admin', 'system', 'user'
        sa.Column('action', sa.String(50), nullable=False),
        sa.Column('resource_type', sa.String(50), nullable=False),  # 'report', 'user', 'evidence'
        sa.Column('resource_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('metadata', postgresql.JSONB(), nullable=True),
        sa.Column('created_at', sa.TIMESTAMP(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index('ix_audit_logs_actor_id', 'audit_logs', ['actor_id'])
    op.create_index('ix_audit_logs_resource', 'audit_logs', ['resource_type', 'resource_id'])
    op.create_index('ix_audit_logs_created_at', 'audit_logs', ['created_at'])
    
    # Create deadmans_switches table
    op.create_table(
        'deadmans_switches',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('report_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('reports.id', ondelete='CASCADE'), nullable=False),
        sa.Column('reporter_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=True),
        sa.Column('ngo_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('ngos.id'), nullable=True),
        sa.Column('trigger_type', sa.String(20), nullable=False),  # 'time', 'event', 'manual'
        sa.Column('trigger_config', postgresql.JSONB(), nullable=True),
        sa.Column('status', sa.String(20), nullable=False, server_default='active'),
        sa.Column('triggered_at', sa.TIMESTAMP(timezone=True), nullable=True),
        sa.Column('created_at', sa.TIMESTAMP(timezone=True), server_default=sa.func.now()),
    )
    op.create_index('ix_deadmans_switches_report_id', 'deadmans_switches', ['report_id'])
    op.create_index('ix_deadmans_switches_status', 'deadmans_switches', ['status'])


def downgrade() -> None:
    # Drop tables in reverse order
    op.drop_table('deadmans_switches')
    op.drop_table('audit_logs')
    op.drop_table('report_hashes')
    
    # Remove columns from report_media
    op.drop_column('report_media', 'metadata')
    op.drop_column('report_media', 'hash_sha256')
    
    # Remove columns from reports
    op.drop_column('reports', 'hash_anchored_on_chain')
    op.drop_column('reports', 'legal_advice_snapshot')
    op.drop_column('reports', 'fake_confidence')
    op.drop_column('reports', 'is_likely_fake')
    op.drop_column('reports', 'recommended_agency')
    op.drop_column('reports', 'ai_category')
    op.drop_column('reports', 'priority_score')
    op.drop_column('reports', 'report_id')

# Use official uv image with Python 3.11
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim

WORKDIR /app

# Ensure unbuffered logs and bytecode compilation
ENV PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

# Install project dependencies first (cached layer)
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-install-project --no-dev

# Copy application files
COPY . .

# Final project install
RUN uv sync --frozen --no-dev

# Expose Streamlit port
EXPOSE 8501

# Run sample pipeline if no scores exist, then launch dashboard
CMD ["sh", "-c", "if [ ! -f data/output/scores.parquet ]; then echo '==> Initializing with sample pipeline...' && uv run python run.py --mode sample; fi && echo '==> Launching ChainLens Dashboard on http://localhost:8501...' && uv run streamlit run dashboard.py --server.port=8501 --server.address=0.0.0.0 --browser.gatherUsageStats=false"]

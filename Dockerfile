FROM python:3.11.2-slim-bullseye AS builder

RUN apt-get update && apt-get upgrade -y

RUN useradd --create-home webapp
USER webapp
WORKDIR /home/webapp

ENV VIRTUALENV=/home/webapp/venv
RUN python3 -m venv $VIRTUALENV
ENV PATH="$VIRTUALENV/bin:$PATH"

COPY --chown=webapp pyproject.toml constraints.txt ./

RUN python -m pip install --upgrade pip setuptools && \
    python -m pip install --no-cache-dir -c constraints.txt ".[dev]"

COPY --chown=webapp src/ src/
COPY --chown=webapp tests/ tests/

RUN python -m pip install . -c constraints.txt && \
    python -m pytest tests/unit && \
    python -m flake8 src/ && \
    python -m isort src/ --check && \
    python -m black src/ --check --quiet && \
    python -m pylint src/ --disable=C0114,C0116,R1705 && \
    python -m bandit -r src/ --quiet && \
    python -m pip wheel --wheel-dir dist/ . -c constraints.txt


FROM python:3.11.2-slim-bullseye

RUN apt-get update && \
    apt-get upgrade --yes

RUN useradd --create-home webapp
USER webapp
WORKDIR /home/webapp

ENV VIRTUALENV=/home/webapp/venv
RUN python3 -m venv $VIRTUALENV
ENV PATH="$VIRTUALENV/bin:$PATH"

COPY --from=builder /home/webapp/dist/financial*.whl /home/webapp
RUN echo $(ls .)
RUN python -m pip install --upgrade pip setuptools && \
    python -m pip install --no-cache-dir financial*.whl

CMD ["uvicorn", "src.dashboard.app:app"]
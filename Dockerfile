FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Python 출력 버퍼링을 비활성화하여 실시간으로 로그를 확인할 수 있도록 함
ENV PYTHONUNBUFFERED=1
# Python이 모듈을 찾을 경로를 설정합니다.
ENV PYTHONPATH=/app

# pip로 의존성 직접 설치 (pyproject.toml의 dependencies 사용)
RUN pip install --no-cache-dir \
    "python-dotenv>=1.1.1,<2.0.0", \
    "langchain>=0.3.26,<0.4.0", \
    "langchain-openai>=0.3.27,<0.4.0", \
    "langchain-community>=0.3.26,<0.4.0", \
    "pypdf>=5.7.0,<6.0.0", \
    "gradio>=5.35.0,<6.0.0", \
    "gradio-pdf>=0.0.22,<0.0.23", \
    "faiss-cpu>=1.11.0,<2.0.0"

    # 소스 코드 복사
COPY src/ ./src/

# 업로드된 PDF 파일을 저장할 디렉토리 생성
RUN mkdir -p /app/uploads

# Gradio가 사용하는 포트 노출
EXPOSE 7860

# 보안을 위해 root가 아닌 일반 사용자(appuser)를 생성하고 실행합니다.
RUN useradd --create-home --shell /bin/bash appuser && \
    chown -R appuser:appuser /app
# 애플리케이션 디렉토리의 소유권을 해당 사용자에게 부여합니다.    
USER appuser

# 애플리케이션 실행 (모듈로 실행)
CMD ["python", "src/main.py"]
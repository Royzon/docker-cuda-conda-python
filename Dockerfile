ARG CUDA_VERSION=11.2.2

FROM nvidia/cuda:${CUDA_VERSION}-devel

ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/London"

RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake \
        git \
        wget \
        curl \
        unzip \
        vim \
        ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /root/.cache && \
    rm -rf /var/lib/apt/lists/*

# Leave these args here to better use the Docker build cache
ARG CONDA_VERSION=py38_4.9.2
ARG PYTHON_VERSION=3.8

# Install miniconda for containeruser
RUN curl -o ~/miniconda.sh -O  https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh  && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -ya

# Install Python and upgrade pip
ENV PATH /opt/conda/bin:$PATH
COPY adjust_conda_requirements.py adjust_conda_requirements.py
COPY conda_requirements.yaml conda_requirements.yaml
RUN conda install python=${PYTHON_VERSION} pyyaml -c anaconda -c conda-forge
RUN echo ${CUDA_VERSION}
RUN python adjust_conda_requirements.py --conda_file=conda_requirements.yaml --python_version=${PYTHON_VERSION} --cuda_version=${CUDA_VERSION} && rm adjust_conda_requirements.py
RUN conda env update --name=base --file conda_requirements.yaml && rm conda_requirements.yaml

RUN pip install --upgrade pip

CMD ["/bin/bash"]

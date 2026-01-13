ARG from_tag=20260109-0020

FROM discourse/discourse_dev:${from_tag}

USER discourse
WORKDIR /workspace
RUN git clone https://github.com/discourse/discourse --single-branch --branch stable

USER root

FROM rust:1.57.0-slim AS build

# Version numbers for all the crates we're going to install
ARG MDBOOK_VERSION="0.4.18"
ARG MDBOOK_LINKCHECK_VERSION="0.7.6"
ARG MDBOOK_MERMAID_VERSION="0.8.3"
ARG MDBOOK_TOC_VERSION="0.7.0"
ARG MDBOOK_PLANTUML_VERSION="0.7.0"
ARG MDBOOK_OPEN_ON_GH_VERSION="2.0.1"
ARG MDBOOK_GRAPHVIZ_VERSION="0.0.2"
ARG MDBOOK_KATEX_VERSION="0.2.10"

ENV CARGO_INSTALL_ROOT /usr/local/
ENV CARGO_TARGET_DIR /tmp/target/

RUN apt-get update && \
    apt-get install -y libssl-dev pkg-config ca-certificates build-essential make perl gcc libc6-dev

RUN cargo install mdbook --vers ${MDBOOK_VERSION} --verbose
RUN cargo install mdbook-linkcheck --vers ${MDBOOK_LINKCHECK_VERSION} --verbose
RUN cargo install mdbook-mermaid --vers ${MDBOOK_MERMAID_VERSION} --verbose
RUN cargo install mdbook-toc --vers ${MDBOOK_TOC_VERSION} --verbose
RUN cargo install mdbook-plantuml --vers ${MDBOOK_PLANTUML_VERSION} --verbose
RUN cargo install mdbook-open-on-gh --vers ${MDBOOK_OPEN_ON_GH_VERSION} --verbose
RUN cargo install mdbook-graphviz --vers ${MDBOOK_GRAPHVIZ_VERSION} --verbose
RUN cargo install mdbook-katex --vers ${MDBOOK_KATEX_VERSION} --verbose


# Install plantuml and dependencies
ENV PLANTUML_VERSION=1.2022.5
ENV LANG en_US.UTF-8
RUN apt-get update && apt-get install --no-install-recommends -y wget ca-certificates
RUN mkdir -p /usr/share/plantuml
RUN wget "http://downloads.sourceforge.net/project/plantuml/${PLANTUML_VERSION}/plantuml.${PLANTUML_VERSION}.jar" -O /usr/share/plantuml/plantuml.jar

# Create the final image
FROM eclipse-temurin:11-jre-focal

COPY --from=build /usr/share/plantuml/plantuml.jar /usr/share/plantuml/plantuml.jar

RUN apt-get update && apt-get install --no-install-recommends -y graphviz fonts-dejavu-core fontconfig

RUN ["java", "-Djava.awt.headless=true", "-jar", "/usr/share/plantuml/plantuml.jar", "-version"]
RUN ["dot", "-version"]

LABEL maintainer="david@davidheath.org"
ENV RUST_LOG info

# used when serving
EXPOSE 3000

COPY --from=build /usr/local/bin/mdbook* /bin/

COPY bin/plantuml /usr/bin/plantuml

WORKDIR /data
VOLUME [ "/data" ]

ENTRYPOINT [ "/bin/mdbook" ]

# Google managed base images
FROM marketplace.gcr.io/google/debian10

# Install Dependencies.
RUN apt-get update -y \
&& apt-get install -y \
bash \
curl \
file \
git \
unzip \
xz-utils \
zip \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# Install Flutter.
ENV FLUTTER_ROOT="/opt/flutter"
RUN git clone https://github.com/flutter/flutter.git -b beta --depth 1 "${FLUTTER_ROOT}"
ENV PATH="${FLUTTER_ROOT}/bin:${PATH}"

# Disable analytics and crash reporting on the builder.
RUN flutter config --no-analytics

# Perform a doctor run
RUN flutter doctor -v

ENTRYPOINT [ "flutter" ]

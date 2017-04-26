# =========================================================================== #
# Ionic 3 Docker Image
# =========================================================================== #
FROM node:latest

MAINTAINER Josue Tapia <josnet.tapper@gmail.com>

LABEL Description="Interactive Ionic 3 Framework"

# =========================================================================== #
# USER & GROUP
# =========================================================================== #
# add our user and group first to make sure their IDs get assigned consistently,
# regardless of other deps added later
RUN groupadd -r -o --gid 1000 ionic \
  && useradd -r -o --uid 1000 --gid ionic --shell /bin/bash ionic

RUN echo 'ionic ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# =========================================================================== #
# Environment variables
# =========================================================================== #
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV ANT_HOME /usr/share/ant

ENV MAVEN_VERSION 3.3.9
ENV MAVEN_HOME /opt/maven/apache-maven-${MAVEN_VERSION}
ENV MAVEN_URL http://www-eu.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz

ENV GRADLE_VERSION 3.4.1
ENV GRADLE_HOME /opt/gradle/gradle-${GRADLE_VERSION}
ENV GRADLE_URL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip

ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_BUILD_TOOLS_VERSION 22.0.1
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/tools_r25.2.5-linux.zip

# License Id: android-sdk-license-c81a61d9
# Android 5.1.1 - Revision 2
ENV ANDROID_5_COMPONENTS android-22,build-tools-23.0.3

# Android 4.4.4 - Revision 4
ENV ANDROID_4_4_COMPONENTS android-19,build-tools-22.0.1

# Android 4.0.3 - Revision 5
ENV ANDROID_4_0_COMPONENTS android-15,build-tools-19.1.0

ENV GOOGLE_EXTRAS_COMPONENTS extra-android-support,extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services
ENV GOOGLE_APIS_COMPONENTS addon-google_apis-google-22

ENV WORKSPACE=/workspace/app
ENV PROJECTS=/projects
ENV IONIC_SERVE_PORT=8100
ENV	IONIC_LIVERELOAD_PORT=35729

RUN echo ANDROID_HOME="${ANDROID_HOME}" >> /etc/environment

RUN dpkg-reconfigure debconf -f noninteractive

ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin

VOLUME ${PROJECTS}

# =========================================================================== #
# Pre-install
# =========================================================================== #
RUN \
  apt-get update -qqy \
  && dpkg --add-architecture i386 \
  && apt-get update -qqy \
  && apt-get install -qqy --force-yes \
	expect \
	ant \
	wget \
	zip \
	libc6-i386 \
	lib32stdc++6 \
	lib32gcc1 \
	lib32ncurses5 \
	lib32z1

# =========================================================================== #
# Install
# =========================================================================== #

# -----------------------------------------------------------------------------
# MAVEN
# -----------------------------------------------------------------------------
RUN mkdir -p /opt/maven \
	&& wget -qO - ${MAVEN_URL} | tar xz -C /opt/maven/

# -----------------------------------------------------------------------------
# GRADLE
# -----------------------------------------------------------------------------
RUN mkdir -p /opt/gradle \
	&& wget -qO gradle.zip ${GRADLE_URL} \
	&& unzip -q gradle.zip -d /opt/gradle/ \
	&& rm -f gradle.zip

# -----------------------------------------------------------------------------
# JAVA
# -----------------------------------------------------------------------------
# Add Java 8 PPA
RUN touch /etc/apt/sources.list.d/java-8-debian.list \
	&& echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/java-8-debian.list \
	&& echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list.d/java-8-debian.list

# Now import GPG key on your system for validating packages before installing them
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886

# Automatically accept the Oracle license
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | /usr/bin/debconf-set-selections

# Install Java 8
RUN apt-get update \
	&& apt-get install -y oracle-java8-installer

# -----------------------------------------------------------------------------
# ANDROID
# -----------------------------------------------------------------------------
# Download Android SDK
RUN mkdir -p /opt/android-sdk \
	&& wget -qO android-sdk.zip ${ANDROID_SDK_URL} \
	&& unzip -q android-sdk.zip -d ${ANDROID_HOME} \
	&& rm -f android-sdk.zip

# -----------------------------------------------------------------------------
# IONIC
# -----------------------------------------------------------------------------
# Install cordova and ionic 3 framework
RUN npm install -g cordova \
	&& npm install -g ionic typescript

# Dependency warning - Fix
RUN echo n | cordova -v
RUN ionic info

# =========================================================================== #
# Post-install
# =========================================================================== #

# Install Android SDKs
RUN echo y | android update sdk --no-ui --all --filter platform-tools | grep 'package installed'

# Install other build packages
RUN echo y | android update sdk --no-ui --all --filter "${ANDROID_5_COMPONENTS}" ; \
	echo y | android update sdk --no-ui --all --filter "${ANDROID_4_4_COMPONENTS}" ; \
	echo y | android update sdk --no-ui --all --filter "${ANDROID_4_0_COMPONENTS}" ; \
    echo y | android update sdk --no-ui --all --filter "${GOOGLE_EXTRAS_COMPONENTS}" ; \
    echo y | android update sdk --no-ui --all --filter "${GOOGLE_APIS_COMPONENTS}"

# =========================================================================== #
# Clean up
# =========================================================================== #
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& rm -rf /src/*.deb \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& npm cache clean

# -----------------------------------------------------------------------------
# Demo ionic
# -----------------------------------------------------------------------------
RUN echo n | ionic start ${WORKSPACE} sidemenu --v2 --ts

# Set the working directory to app workspace directory
WORKDIR ${WORKSPACE}

# Expose port: web (8100), livereload (35729)
EXPOSE ${IONIC_SERVE_PORT} ${IONIC_LIVERELOAD_PORT}

# Specify the user to execute all commands below
#USER ionic

CMD ["ionic", "serve", "--all", "--port", "${IONIC_SERVE_PORT}", "--livereload-port", "${IONIC_LIVERELOAD_PORT}"]
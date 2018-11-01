# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
FROM 	   carlosjustino/wso2-os-base
MAINTAINER Carlos Eduardo Justino <carlos.justino@datacoper.com.br>

#######
## SVN 
#######

RUN  apt-get update -y && \
     apt-get upgrade -y && \
     apt-get dist-upgrade -y && \
     apt-get -y autoremove && \
     apt-get clean
RUN apt-get install -y subversion rsync \
    && rm -rf /var/lib/apt/lists/*

VOLUME ["/opt/ambiente/GeradorDatacoper/target", "/opt/ambiente/GeradorDatacoper/src/main/scripts/banco"]
VOLUME ["/opt/ambiente/AgroRevendaJNG"]
VOLUME ["/opt/ambiente/business"]
VOLUME ["/opt/ambiente/core"]
VOLUME ["/opt/ambiente/Mapas"]
VOLUME ["/opt/ambiente/resources"]
VOLUME ["/root/.subversion/auth"]
VOLUME ["/opt/wso2"]
VOLUME ["/opt/tmp"]
VOLUME ["/opt/freemind"]
	
###########################################

ARG JAVA_MAX_MEM
ENV JAVA_MAX_MEM ${JAVA_MAX_MEM:-2G}

ARG JAVA_START_MEM
ENV JAVA_START_MEM ${JAVA_START_MEM:-500m}

ENV JAVA_OPTS="-Xms$JAVA_START_MEM -Xmx$JAVA_MAX_MEM"

RUN echo "JAVA_OPTS="$JAVA_OPTS

WORKDIR /opt

########## 
## MAVEN
##########

RUN mkdir /opt/maven

WORKDIR /opt/maven
ADD packs/apache-maven-3.5.4-bin.tar.gz /opt/maven
RUN ln -snf /opt/maven/apache-maven-3.5.4 producao

RUN export PATH=/opt/maven/producao/bin:$PATH
RUN export M2_HOME=/opt/maven/producao
ENV M2_HOME /opt/maven/producao
RUN echo "export M2_HOME=/opt/maven/producao" >> /root/.bashrc
RUN echo "export PATH=/opt/maven/producao/bin:$PATH" >> /root/.bashrc
ENV PATH /opt/maven/producao/bin:$PATH

COPY files/settings.xml /opt/maven/producao/conf

########## 
## WSO2
##########

WORKDIR /opt

WORKDIR /opt/wso2

RUN export HOME_WSO2=/opt/wso2

ENV HOME_WSO2 /opt/wso2

########## 
## AMBIENTE
##########

WORKDIR /opt

RUN export apresentaCoresTerminal=true
ENV apresentaCoresTerminal true

RUN export HOME_TEMP=/opt/tmp
ENV HOME_TEMP /opt/tmp

RUN export HOME_FREEMIND=/opt/freemind
ENV HOME_FREEMIND /opt/freemind

WORKDIR /opt/ambiente

ADD packs/GeradorDatacoper.zip  /opt/ambiente
RUN unzip -q GeradorDatacoper.zip
run rm GeradorDatacoper.zip

WORKDIR /opt/ambiente/GeradorDatacoper

RUN export MY_WORKSPACE=/opt/ambiente/GeradorDatacoper/src/main/scripts/workspace
ENV MY_WORKSPACE /opt/ambiente/GeradorDatacoper/src/main/scripts/workspace

RUN export PATH=$MY_WORKSPACE:$PATH
ENV PATH $MY_WORKSPACE:$PATH

RUN chmod a+x /opt/ambiente/GeradorDatacoper/src/main/scripts/workspace/*.sh 
RUN chmod a+x /opt/ambiente/GeradorDatacoper/src/main/scripts/base/*.sh 

RUN echo "export M2_HOME=/opt/maven/producao" >> /root/.bashrc
RUN echo "export PATH=$MY_WORKSPACE:$PATH" >> /root/.bashrc

###################
# Setup run script
###################
WORKDIR $MY_WORKSPACE

RUN svn --version	
RUN mvn --version
RUN java -version
RUN generate.sh --info

CMD ["bash"]
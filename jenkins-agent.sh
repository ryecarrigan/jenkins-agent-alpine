#!/usr/bin/env bash
################################################################################
# The MIT License
#
#  Copyright (c) 2015, CloudBees, Inc.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.
################################################################################

# Usage:
#   agent.sh [options] -url http://jenkins SECRET AGENT_NAME
#
# Required environment variables:
#   AGENT_JAR
#       * Location of the Jenkins remoting agent JAR
#
# Optional environment variables:
#   JAVA_OPTS
#       * Java command-line options
#   JENKINS_URL
#       * Jenkins base URL (instead of providing through run args)
#   JENKINS_TUNNEL
#       * HOST:PORT for a tunnel to route TCP traffic to Jenkins host, for when
#         Jenkins can't be directly accessed over the network
#   JNLP_PROTOCOL_OPTS
#       * Option to override default disabling of JnlpProtocol3


# If "docker run" only has one argument, then we run that as a command.
if [ $# -eq 1 ]; then
    exec "$@"

# Otherwise, follow through with agent connection procedure.
else
    # If AGENT_JAR is not set, then set it to the default value
    if [ -z "${AGENT_JAR}" ]; then
        AGENT_JAR="/usr/share/jenkins/slave.jar"
    fi

    # Confirm that the agent JAR is a file
    if [ ! -f ${AGENT_JAR} ]; then
        echo "Error: Agent JAR is missing or the provided location is incorrect"
        exit -1
    fi

    # If "-tunnel" is not provided in the arguments, check the environment
    if [[ "$@" != *"-tunnel "* ]]; then
        if [ ! -z "${JENKINS_TUNNEL}" ]; then
            TUNNEL="-tunnel ${JENKINS_TUNNEL}"
        fi
    fi

    # If JENKINS_URL is set in the environment, try to use that as the URL
    if [ ! -z "$JENKINS_URL" ]; then
        URL="-url $JENKINS_URL"
    fi

    # If provided, optionally alter the behavior for disabling JnlpProtocol
    if [ -z "$JNLP_PROTOCOL_OPTS" ]; then
        echo "Warning: JnlpProtocol3 is disabled by default, use JNLP_PROTOCOL_OPTS to alter the behavior"
        JNLP_PROTOCOL_OPTS="-Dorg.jenkinsci.remoting.engine.JnlpProtocol3.disabled=true"
    fi

    # Finally, launch the agent JAR with any options
    exec java ${JAVA_OPTS} ${JNLP_PROTOCOL_OPTS} -cp ${AGENT_JAR} hudson.remoting.jnlp.Main -headless $TUNNEL ${URL} "$@"
fi

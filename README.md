# Update (Jan 18, 2018): Maintenance is on-demand. Please create an issue, if you need support in using this integration.

# Dynatrace OneAgent for PaaS: S2I Builder Image Integrations

This project provides integrations of [Dynatrace OneAgent for PaaS](https://github.com/dynatrace-innovationlab/oneagent-paas-install) into [S2I builder images](https://github.com/openshift/source-to-image/blob/master/docs/builder_image.md) for various technologies.

## Usage

The `dynatrace-monitoring-incl.sh` file supports single-line integrations of OneAgent for PaaS into S2I's [assemble](https://github.com/openshift/source-to-image/blob/master/docs/builder_image.md#assemble) and [run](https://github.com/openshift/source-to-image/blob/master/docs/builder_image.md#run) scripts. This means that the same file can be used to enable OneAgent for PaaS installations either at a container's *build time*, *runtime*, *or both*. Once `dynatrace-monitoring-incl.sh` has been put in place, it triggers a OneAgent for PaaS installation if requested by the user. An exemplary integration into `assemble` and `run` can be seen in the [examples/s2i](https://github.com/dynatrace-innovationlab/oneagent-paas-s2i-integrations/tree/master/examples/s2i) directory.

## Required Environment Variables

| Name               | Description                                            |
|--------------------|--------------------------------------------------------|
| `ENABLE_DYNATRACE` | Set to `true` if OneAgent for PaaS shall be installed. |
| `DT_TENANT`        | Your Dynatrace Tenant (Environment ID).                |
| `DT_API_TOKEN`     | Your Dynatrace API Token.                              |

## Optional Environment Variables

Please refer to the [Dynatrace OneAgent for PaaS](https://github.com/dynatrace-innovationlab/oneagent-paas-install) documentation for a list of other supported environment variables.

## Examples

### Integrate at application container build time

1) Integrate `dynatrace-monitoring-incl.sh` into `openshift/wildfly-101-centos7`:

```
git clone https://github.com/openshift-s2i/s2i-wildfly.git
cd ./s2i-wildfly/10.1

cp dynatrace-monitoring-incl.sh ./s2i/bin
docker build -t openshift/wildfly-101-centos7:dynatrace .
```

2) Build an application container and integrate OneAgent for PaaS:

```
s2i build                                               \
  https://github.com/openshift/openshift-jee-sample.git \
  openshift/wildfly-101-centos7:dynatrace               \
  wildflytest                                           \
  --env=ENABLE_DYNATRACE=true                           \
  --env=DT_TENANT=abc                                   \
  --env=DT_API_TOKEN=123                                \
  --env=DT_ONEAGENT_FOR=java
```

3) Run the application monitored by Dynatrace:

```
docker run wildflytest
```

### Integrate at application container runtime

1) Integrate `dynatrace-monitoring-incl.sh` into `openshift/wildfly-101-centos7`:

```
git clone https://github.com/openshift-s2i/s2i-wildfly.git
cd ./s2i-wildfly/10.1

cp dynatrace-monitoring-incl.sh ./s2i/bin
docker build -t openshift/wildfly-101-centos7:dynatrace .
```

2) Build an application container:

```
s2i build                                               \
  https://github.com/openshift/openshift-jee-sample.git \
  openshift/wildfly-101-centos7:dynatrace               \
  wildflytest
```

3) Integrate OneAgent for PaaS and run the application monitored by Dynatrace:

```
docker run --rm wildflytest   \
  --env ENABLE_DYNATRACE=true \
  --env DT_TENANT=abc         \
  --env DT_API_TOKEN=123      \
  --env DT_ONEAGENT_FOR=java
```

## Testing

We use [Test Kitchen](http://kitchen.ci) together with [Serverspec](http://serverspec.org) to automatically test our installations:

1) Install Test Kitchen and its dependencies from within the project's directory:

```
gem install bundler
bundle install
```

2) Run all tests

```
kitchen test
```

## Disclaimer

This module is supported by the Dynatrace Innovation Lab. Please use the issue tracker to report any problems or ask questions.

## License

Licensed under the MIT License. See the LICENSE file for details.

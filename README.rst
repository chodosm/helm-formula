==================================
helm-formula
==================================

This formula installs and configures the Helm client on the target minion and 
optionally deploys Tiller to the configured Kubernetes cluster. This formula
is additionally capable of proxying management of the releases deployed through
Helm to the Kubernetes cluster.

This formula is intended to be flexible enough to allow users to use it for 
anything from just installing a local Helm binary to managing the releases in
a Tiller deployment.

OS Compatibility
================

Tested with:

* Ubuntu 14.04 LTS

Note
====

This formula is young and interacts with a pretty deep technology stack with 
many varied use cases. Contributions in the form of issues, pull requests, or 
discussions are very welcome.

Availale States
===============

The default state applied by this formula (e.g. if just applying `helm`) will
apply the `helm.releases_managed` state, which:

* installs and configures the Helm client; and
* creates and configures a kubectl config file at a non-standard path (will 
  use default connection parameters).

.. contents::
    :local:

``kubectl_configured``
----------------------

Manages a kubectl configuration file per the configured pillar values. Note 
that the available configuration values allow the path of the kube config file 
to be placed at a different location than the default kube config file. It is
strongly recommended to take advantage of this to ensure the helm client is
connecting to the desired kubernetes cluster.

``client_installed``
------------------

Installs the helm client binary per the configured pillar values, such as where 
helm home should be, which version of the helm binary to install and that path
for the helm binary.

``tiller_installed``
------------------

Optionally installs a Tiller deployment to the kubernetes cluster per the
`helm:client:tiller:install` pillar value. If the pillar value is set to 
install tiller to the cluster, the version of the tiller installation will
match the version of the Helm client installed per the `helm:client:version`
configuration parameter

**includes**:

* `client_installed`
* `kubectl_configured`

``repos_managed``
------------------

Ensures the repositories configured per the pillar (and only those repositories) 
are registered at the configured helm home, and synchronizes the local cache 
with the remote repository with each state execution.

**includes**:

* `client_installed`

``releases_managed``
------------------

Ensures the releases configured with the pillar are in the expected state with
the Kubernetes cluster. This state includes change detection to determine 
whether the pillar configurations match the release's state in the cluster.

Note that changes to an existing release's namespace will trigger a deletion and 
re-installation of the release to the cluster.

**includes**:

* `client_installed`
* `tiller_installed`
* `kubectl_configured`
* `repos_managed`

Availale Modules
===============

To view documentation on the available modules, run: 

.. code-block:: shell
  
  salt '{{ tgt }}' sys.doc helm`

Sample Pillar
==============

See the [pillar.example](pillar.example) for a documented example pillar file.

The default pillar configuration will attempt to install the helm client on the 
target node and a Tiller deployment to the Kubernetes cluster configured in
the kubectl config file (per the `helm:kubectl:config_file` pillar.

Known Issues
============

1. Unable to remove all user supplied values

  If a release previously has had user supplied value overrides (via the 
  release's `values` key in the pillar), subsequently removing all `values`
  overrides (so that there is no more `values` key for the release in the 
  pillar) will not actually update the Helm deployment. To get around this,
  specify a fake key/value pair in the release's pillar; Tiller will override
  all previously user-supplied values with the new fake key and value. For 
  example:


  .. code:: yaml
    
    helm:
      client:
        releases:
          my_release:
            enabled: true
            ...
            values:
              fake_key: fake_value

Contributions
=============

Contributions are always welcome. The main development guidelines include:

* write clean code (proper YAML+Jinja syntax, no trailing whitespaces, no empty 
  lines with whitespaces
* set sane default settings
* test your code
* update README.rst doc

Testing
=======

Running the tests requires a couple local pre-requisites:

* a recent version of Ruby (with Bundler installed);
* Docker installed and running

Running the tests:

.. code-block:: shell

  bundle
  kitchen test

Due to the complexity of the pre-requisites involved (a running kubernetes 
cluster), the tests don't covery any tiller interaction, including deployment
of a tiller instance to the cluster or release managmeent.

Development
===========

The fastest workflow for development is to use `kitchen converge` when you've
modified the formula, and `kitchen verify` when you've modified the specs.

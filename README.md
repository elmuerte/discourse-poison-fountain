# Discourse Poison Fountain

This [Discourse](https://discourse.com) plugin adds a [poison fountain](https://rnsaffn.com/poison3/).

It adds hidden links to every page which point to content which contains subtle flaws that can poison
LLM models when the content is used for training.

Nice web scrapers should not pick up this poisoned content. Users should also not notice any of this.

For more information and discussion see [this thread](https://meta.discourse.org/t/discourse-poison-fountain/393924) on the Discourse Meta forum.

## Plugin Compatibility Status

[![Discourse latest](https://github.com/magicball-network/discourse-poison-fountain/actions/workflows/latest.yml/badge.svg)](https://github.com/magicball-network/discourse-poison-fountain/actions/workflows/latest.yml)

[![Discourse stable](https://github.com/magicball-network/discourse-poison-fountain/actions/workflows/stable.yml/badge.svg)](https://github.com/magicball-network/discourse-poison-fountain/actions/workflows/stable.yml)

The above status is based on the plugin's executed tests against the specified Discourse branch.
It is no definite guarantee that there no issues.

# Pricing rule group selection

Pricing rule group selection functionality is designed to allow retrieval of pricing rule group codes dynamically. 
The codes are retrieved through Apex plugins which exist as a part of the package (out-of-the-box) or custom Apex implementations which cover specific business use cases.

## Usage from Apex

Pricing rule group selection is invoked by executing the global selectPrg method from the PrgSelector Apex class.

Example:

```Java
global static Set<String> selectPrgs(
  String salesAppId,
  User user,
  String basketId,
  Map<String, String> salesContext
);

Set<String> prgs = cspsi.PrgSelector.selectPrgs(...);
```

| Property | Description |
| - | :-- |
| salesAppId | Identifier of a sales app. |
| user | The sales user. |
| basketId | Reference to the Configurator Product Basket record. |
| salesContext | Additional optional context for the plugin. |

## Plugin registration

To register a plugin custom metadata type (csutil\_\_Json_Metadata\_\_mdt) records or custom settings (csutil\_\_Json_Settings\_\_c) records from the CSUtil package are used.

The name of a prg selector plugin must follow the following convention:
PSI/PrgSelectors/**sequence**, e.g. \
PSI/PrgSelectors/1, PSI/PrgSelectors/2, etc.

Example of a plugin registration:

- Name: **PSI/PrgSelectors/1**
- Plugin registration json:

```JSON
{
  "className": "MyPluginApexClass",
  "configuration": "<stringified plugin configuration>",
  "version": "1-0-0"
}
```

## Out-of-the-box plugins

### DefaultPrgSelector

Provides a single prg code as the default fallback if everything else fails. The code is read from the JSON configuration of the plugin.

Class name: **cspsi.DefaultPrgSelector**

Example of a plugin configuration:

```JSON
{
  "version": "1-0-0",
  "prgCodes": ["PRG1"]
}
```

| Property | Description |
| -  | :-- |
| version  | Version identifier. |
| prgCodes | List of prg codes returned. |

### SegmentPrgSelector

Provides a list of prg codes for a certain segment identified by a field on the Account record.

Class name: **cspsi.SegmentPrgSelector**

Example of a plugin configuration:

```JSON
{
  "version": "1-0-0",
  "fieldPath": "Account.Industry",
  "prgsBySegment": {
    "Agriculture": ["PRG1", "PRG2"],
    "Finance": ["PRG2", "PRG3"]
  },
  "exclusive": false
}
```

| Property | Description |
| -  | :--  |
| version | Version identifier. |
| fieldPath | Field to read the segment identifier from. |
| prgsBySegment | A map of segment identifiers and their prg code mappings. |
| exclusive | If true, empties prg codes retrieved up to invocation of the plugin and returns own prg codes (if any are identified). |

### ChannelPrgSelector

Provides a list of prg codes for a certain sales channel.

Class name: **cspsi.ChannelPrgSelector**

Example of plugin configuration:

```JSON
{
  "version": "1-0-0",
  "prgsBySalesApp": {
    "MySalesApp": ["PRG1", "PRG2"]
  },
  "exclusive": false
```

| Property | Description |
| -  | :--  |
| version | Version identifier. |
| prgsBySalesApp | A map of sales app names and their prg code mappings. |
| exclusive | If true, empties prg codes retrieved up to invocation of the plugin and returns own prg codes (if any are identified). |

## Custom plugin implementation

![]({{images}}/prg-selection.png)

A custom plugin needs to implement the globally exposed interface APrgSelector in order to be callable/usable.

Every custom plugin inherits a field of type String named **configuration**. This configuration field is automatically injected during plugin instantiation.

```Java
global class CustomPrgSelector extends cspsi.APrgSelector {
    global override void selectPrgs(
      String salesAppId,
      User user,
      String basketId,
      Map<String, String> salesContext,
      Set<String> prgs
    ) {
        Map<String, Object> configurationMap =
            (Map<String, Object>) Json.deserializeUntyped(this.configuration);

        if (configurationMap.get('some-property') == 'some-value') {
            prgs.add('PRG-123');
        } else {
            prgs.add('PRG-456');
        }
    }
}
```

| Property | Description |
| - | :-- |
| salesAppId | Identifier of a sales app. |
| user | The sales user. |
| basketId | Reference to the Configurator Product Basket record. |
| salesContext | Additional optional context for the plugin. |
| prgs | A set of previously selected prg codes. The plugin can add to the set, remove from it or do nothing. |

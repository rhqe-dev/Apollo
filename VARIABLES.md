Apollo CNC  //  TFX Variable Reference

##### resources/branding/title.tfx #####

`Response Type: string`
{$cnc.uptime}                           `Description` How long the CNC has been online
`Response Type: int`
{$bots}                             `Description` Fake bot count
{$stub.<name>}                      `Description` Active attacks for stub group — replace <name> with lowercase stub name (e.g. {$stub.l4})
{$stub.<name>.max}                  `Description` Concurrent cap for stub group — replace <name> with lowercase stub name (e.g. {$stub.l4.max})
{$total.online}                     `Description` Active operator sessions

##### resources/branding/prompt.tfx #####

`Response Type: string`
{$user}                             `Description` Logged-in username

##### resources/branding/help.tfx #####

Note: All variables from the "All .tfx Files" section below are also available here.
`Response Type: string`
{$user}                             `Description` Username padded to 20 chars
{$role}                             `Description` Role padded to 22 chars
{$expiry}                           `Description` Expiry date padded to 54 chars
`Response Type: int`
{$bots}                             `Description` Fake bot count padded to 20 chars
{$cnc.uptime}                       `Description` CNC uptime padded to 22 chars

##### resources/branding/attack_sent.tfx #####

Note: All variables from the "All .tfx Files" section below are also available here.
`Response Type: none`
{$sleep.10}                         `Description` Sleep for 10 milliseconds
{$sleep.20}                         `Description` Sleep for 20 milliseconds
{$sleep.100}                        `Description` Sleep for 100 milliseconds
{$sleep.200}                        `Description` Sleep for 200 milliseconds
{$sleep.300}                        `Description` Sleep for 300 milliseconds
{$sleep.400}                        `Description` Sleep for 400 milliseconds
{$sleep.500}                        `Description` Sleep for 500 milliseconds
{$sleep.600}                        `Description` Sleep for 600 milliseconds
{$sleep.700}                        `Description` Sleep for 700 milliseconds
{$sleep.800}                        `Description` Sleep for 800 milliseconds
{$sleep.900}                        `Description` Sleep for 900 milliseconds
{$sleep.1000}                       `Description` Sleep for 1000 milliseconds (1 second)
`Response Type: string`
{$method.sent}                      `Description` Attack method name uppercase
{$target.method}                    `Description` Alias for method.sent
{$target.ip}                        `Description` Targeted IP or hostname
{$target.host}                      `Description` Alias for target.ip
{$target.time}                      `Description` Attack duration in seconds
{$target.duration}                  `Description` Alias for target.time
{$target.time_sent}                 `Description` Clock time the attack was sent
{$target.region}                    `Description` Region of target
{$target.country}                   `Description` Country of target
{$target.country_code}              `Description` ISO country code
{$target.city}                      `Description` City of target
{$target.zip}                       `Description` Postal code of target
{$target.isp}                       `Description` ISP of target
{$target.org}                       `Description` Organisation of target
{$target.timezone}                  `Description` Timezone of target
`Response Type: int`
{$target.port}                      `Description` Targeted port
{$target.asn}                       `Description` AS number of target
{$bots}                             `Description` Bot count at time of send

##### resources/branding/home.tfx + resources/branding/methods.tfx + All Others #####

`Response Type: none`
{$sleep.10}                         `Description` Sleep for 10 milliseconds
{$sleep.20}                         `Description` Sleep for 20 milliseconds
{$sleep.100}                        `Description` Sleep for 100 milliseconds
{$sleep.200}                        `Description` Sleep for 200 milliseconds
{$sleep.300}                        `Description` Sleep for 300 milliseconds
{$sleep.400}                        `Description` Sleep for 400 milliseconds
{$sleep.500}                        `Description` Sleep for 500 milliseconds
{$sleep.600}                        `Description` Sleep for 600 milliseconds
{$sleep.700}                        `Description` Sleep for 700 milliseconds
{$sleep.800}                        `Description` Sleep for 800 milliseconds
{$sleep.900}                        `Description` Sleep for 900 milliseconds
{$sleep.1000}                       `Description` Sleep for 1000 milliseconds (1 second)
`Response Type: string`
{$clear}                            `Description` Clear the terminal screen
{$skipline}                         `Description` Insert a blank line
{$resize.80w.24h}                   `Description` Resize terminal window — replace 80/24 with target cols/rows
{$resize.auto}                      `Description` Auto-resize terminal to fit the widest line of the current .tfx content (min 80×24, +4 col padding)
{$pad.40w}                          `Description` Insert spaces so visible content on this line reaches column 40 — replace 40 with desired width
{$name.gif}                         `Description` Play resources/gifs/name.gif inline — replace "name" with filename
{$user.username}                    `Description` Logged-in username
{$user.role}                        `Description` User role
{$cnc.name}                         `Description` CNC name
{$cnc.uptime}                       `Description` How long the CNC has been online
{$user.expiry}                      `Description` User expiry date
{$user.vip.expiry}                  `Description` User VIP role expiry (same as expiry when role=vip)
{$user.created_by}                  `Description` Who created this account
{$user.creation.fmt}                `Description` Account creation date formatted
{$user.attacks.latest}              `Description` Most recent target attacked by user
{$user.ssh_client}                  `Description` SSH client version string
{$user.connection}                  `Description` Connection protocol (ssh/telnet)
{$user.theme}                       `Description` User theme name — reserved, blank
{$total.attacks.latest}             `Description` Most recent target attacked globally
{$user.time_until.expiry}           `Description` Days remaining until user expiry
{$user.time_since.creation}         `Description` Days since account was created
`Response Type: int`
{$total.online}                     `Description` Total active operator sessions
{$total.ongoing}                    `Description` Total attacks currently running globally
{$total.attacks.count}              `Description` Total attacks in database
{$user.ongoing}                     `Description` This user's currently active attacks
{$user.concurrents}                 `Description` Max concurrent attacks for this user
{$user.max_time}                    `Description` Max attack duration in seconds
{$user.cooldown}                    `Description` Cooldown between attacks in seconds
{$user.attacks.count}               `Description` Total attacks sent by this user
{$user.max_daily_attacks}           `Description` Daily attack cap
{$user.max_daily_attacks.left}      `Description` Remaining daily attacks today
{$max.slots}                        `Description` Global concurrent attack ceiling
{$fake.bots}                        `Description` Simulated bot count
{$fake.online_users}                `Description` Simulated online user count
`Response Type: bool`
{$user.admin}                       `Description` User Administrator status (true/false)
{$user.mod}                         `Description` User Moderator status (true/false)
{$user.reseller}                    `Description` User Reseller status (true/false)
{$user.vip}                         `Description` User VIP status (true/false)
{$user.mfa}                         `Description` User MFA status — reserved (true/false)
{$user.api_access}                  `Description` User API Access status (true/false)
{$user.bypass_power_saving}         `Description` User Bypass Power Saving status — reserved (true/false)
{$user.bypass_spam_protection}      `Description` User Bypass Spam Protection status — reserved (true/false)
{$user.bypass_blacklist}            `Description` User Bypass Blacklist status — reserved (true/false)
{$user.bypass_soft_max_time}        `Description` User Bypass Soft MaxTime status — reserved (true/false)

# Color Tags:

<ColorName> in a .tfx file wraps all following text in that named gradient until the next tag.
Tags are zero-width at runtime — they consume no visible space on screen.
Colors are defined in resources/settings/colors.json.
Example:  <Mango>Hello World <Skyline>More text

# Resize Terminal:

{$resize.COLSw.ROWSh}               Replace COLS and ROWS with the desired terminal dimensions.
Example:  {$resize.80w.24h}         Resize to 80 columns by 24 rows.

# Padding:

{$pad.Nw} inserts spaces so the visible content on that line reaches column N.
Place it directly after a variable whose value may vary in length (e.g. expiry dates, usernames)
to keep a trailing border character or symbol perfectly aligned.
Color tags and ANSI codes are invisible — they are excluded from the width count.
Example:  │ Expiry: {$user.expiry}{$pad.35w}│
If the content already meets or exceeds N columns, no spaces are inserted.

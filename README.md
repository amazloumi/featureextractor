# featureextractor
These bash scripts extract some features including number of updates, number of announces, and number of withdrawals from BGP update log files.

1. Download bgp update file from routeviews.org (http://archive.routeviews.org/bgpdata/)
2. Convert the bgp update file to bgpdump format or print the whole messages using mrt2bgpdump.py and print_all.py respectively. these two files are parts of mrtparse project found in (https://github.com/YoshiyukiYamauchi/mrtparse.git)
3. now you can use w_a_counter.sh and u_w_counter.sh to extract feature from bgpdump and print_all format respectively. You can extract the features every given interval in seconds.

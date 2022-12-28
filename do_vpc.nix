{
  resource.digitalocean_vpc.default_sgp = {
    name = "default-sgp1";
    ip_range = "10.104.0.0/20";
    region = "sgp1";
  };
  resource.digitalocean_vpc.dummy_sgp = {
    name = "dummy-sgp";
    ip_range = "10.105.69.0/20";
    region = "sgp1";
  };
}

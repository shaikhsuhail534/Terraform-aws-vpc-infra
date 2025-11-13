provider aws {
  region = "Your region"
  access_key = "Your Access key"
  secret_key = "Your secret key"
}

resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}

#Public-subnet
resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet"
  }
}

#Private-subnet
resource "aws_subnet" "privae-subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet"
  }
}


#Security group
resource "aws_security_group" "mysg" {
  name        = "mysg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

ingress {
    description = "TLS from VPC"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "mysg"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
  }
}


#Route table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

  tags = {
    Name = "public-rt"
  }
}


#Route table association to connect subnet 
resource "aws_route_table_association" "public-asso" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

#aws key that you will create using command ssh-keygen in your instance 
resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = "your generated key"
}


resource "aws_instance" "myinstance" {
  ami           = "your ami id" 
  instance_type = "t3.micro"
  subnet_id = "aws_subnet.public-subnet.id"
  vpc_security_group_ids = [aws_security_group.mysg]
  key_name = "mykey"

  tags = {
    Name = "myinstance"
  }
}


# to get the public ip for our instance
resource "aws_eip" "myinstance" {
  instance = aws_instance.myinstance.id
  domain = "vpc"
}



# to create a db server using private subnet
resource "aws_instance" "db-instance" {
  ami           = "your ami id" 
  instance_type = "t3.micro"
  subnet_id = "aws_subnet.private-subnet.id"
  vpc_security_group_ids = [aws_security_group.mysg]
  key_name = "mykey"

  tags = {
    Name = "db-instance"
  }
}

# now as you have created a db server, which does not have a public ip accessing this from 
# the internet will be difficult so create a net gateway to access it from outside
# and as net gateway needs a public ip create a public ip

# to get the public ip for our net gateway
resource "aws_eip" "nat-ip" {
  domain = "vpc"
}


#net gateway
resource "aws_nat_gateway" "my-nat" {
  allocation_id = aws_eip.nat-ip.id
  subnet_id   = aws_subnet.public-subnet.id
}

# now this ownt work until you again create a route table 
# and connect this with your net gateway 
#Route table
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my-nat.id
  }

  tags = {
    Name = "private-rt"
  }
}

#now again a route table association
resource "aws_route_table_association" "private-asso" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}

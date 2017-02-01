function primes = factorize(a, primes)
if ~exist('primes', 'var')
    primes = 2;
end

if a == 1
    return
end

for i = 1 : numel(primes)
    b = primes(i);
    if dividable(a, b)
        disp(b);
        primes = factorize(a / b, primes);
        return
    end
end

b = primes(end) + 1;
while b < a
    while not(isprime(b, primes))
        b = b + 1;
    end
    primes = [primes, b];
    if dividable(a, b)
        disp(b);
        primes = factorize(a / b, primes);
        return
    end
    b = b + 1;
end
disp(b);
primes = [primes, b];

end


function tof = dividable(a, b)
tof = not(rem(a, b));
end

function tof = isprime(a, primes)
tof = true;
for i = 1 : numel(primes)
    b = primes(i);
    if dividable(a, b)
        tof = false;
        return;
    end
end
end

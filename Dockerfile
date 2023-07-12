#premain
FROM ghcr.io/edgelesssys/edgelessrt-dev:latest AS marblerun


RUN git clone --branch=master --depth=1 https://github.com/edgelesssys/marblerun \
    && cd ./marblerun/ \
    && mkdir ./build/ \
    && cd ./build/ \
    && cmake .. \
    && make -j



FROM enclaive/gramine-os:jammy-33576d39

RUN apt-get update \
    && apt-get install -y nodejs npm \
    && rm -rf /var/lib/apt/lists/*

RUN npm install --global yarn

WORKDIR /manifest/


COPY --from=marblerun /marblerun/build/premain-libos /premain/

COPY ./node.manifest.template ./entrypoint.sh /manifest/

#RUN --mount=type=secret,id=signingkey gramine-manifest -Darch_libdir=/lib/x86_64-linux-gnu node.manifest.template node.manifest \
#    && gramine-sgx-sign --key "/run/secrets/signingkey" --manifest node.manifest --output node.manifest.sgx \
#    && gramine-sgx-get-token --output node.token --sig node.sig \
#    && cat -v node.token \
#    && sed -i 's,https://localhost:8081/sgx/certification/v3/,https://172.17.0.1:8081/sgx/certification/v3/,g' /etc/sgx_default_qcnl.conf \
#    && sed -i 's,"use_secure_cert": true,"use_secure_cert": false,g' /etc/sgx_default_qcnl.conf 

#EXPOSE 3000

ENTRYPOINT [ "/manifest/entrypoint.sh" ]
